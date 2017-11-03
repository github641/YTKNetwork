//
//  ViewController.m
//  YTKNetworkDemo
//
//  Created by Chenyu Lan on 10/28/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
/* lzy171103注:
 请求使用示例。
 
 添加xxtea。返回数据的 解密。
 
 YTKNetworkAgent类的.m
 - (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error
 
  380line
 
 #pragma mark - ================== xxtea ==================
 // 调试
 
 //        NSLog(@"原串:%@", @"ok");
 
 //        NSData *data = [XXTEA encryptString:@"ok" stringKey:XXTEAKEYString sign:YES];
 
 // 数据传输
 
 NSData *decodeData = [ZYXXTEA decrypt:responseObject stringKey:@"key" sign:YES];
 
 NSString *decodeString = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
 
 DebugLog(@"decodeString:%@", decodeString);
 
 
 request.responseObject = decodeData;
 // 返回数据若是二进制数据
 if ([request.responseObject isKindOfClass:[NSData class]]) {
 request.responseData = decodeData;
 request.responseString = [[NSString alloc] initWithData:decodeData encoding:[DksNetworkUtils stringEncodingWithRequest:request]];
 // 根据响应序列化类型，处理返回数据
 switch (request.responseSerializerType) {
 case DksResponseSerializerTypeHTTP:
 // Default serializer. Do nothing.
 break;
 case DksResponseSerializerTypeJSON:
 request.responseObject = [self.jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
 request.responseJSONObject = request.responseObject;
 break;
 case DksResponseSerializerTypeXMLParser:
 request.responseObject = [self.xmlParserResponseSerialzier responseObjectForResponse:task.response data:request.responseData error:&serializationError];
 break;
 }
 }

 */

#import "ViewController.h"
#import "YTKBatchRequest.h"
#import "YTKChainRequest.h"
#import "GetImageApi.h"
#import "GetUserInfoApi.h"
#import "RegisterApi.h"
#import "YTKBaseRequest+AnimatingAccessory.h"

@interface ViewController ()<YTKChainRequestDelegate, YTKRequestDelegate>

@end

@implementation ViewController

#pragma mark - ================== 一般请求 ==================
/* lzy171103注:
 普通请求.block回调。
 注意：你可以直接在 block 回调中使用 self，不用担心循环引用。因为 YTKRequest 会在执行完 block 回调之后，将相应的 block 设置成 nil。从而打破循环引用。
 除了 block 的回调方式外，YTKRequest 也支持 delegate 方式的回调：
 */
- (void)loginButtonPressed:(id)sender {
    NSString *username = @"";
    NSString *password = @"";
    if (username.length > 0 && password.length > 0) {
        RegisterApi *api = [[RegisterApi alloc] initWithUsername:username password:password];
        

        
        [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            // 你可以直接在这里使用 self
            NSLog(@"succeed");
        } failure:^(YTKBaseRequest *request) {
            // 你可以直接在这里使用 self
            NSLog(@"failed");
        }];
    }
}

/* lzy171103注:
 普通请求。delegate回调。
         //  api.delegate = self;
 */
- (void)loginButtonPressed2:(id)sender {
    NSString *username = @"";
    NSString *password = @"";
    if (username.length > 0 && password.length > 0) {
        RegisterApi *api = [[RegisterApi alloc] initWithUsername:username password:password];
        api.delegate = self;
        [api start];
    }
}

- (void)requestFinished:(YTKBaseRequest *)request {
    NSLog(@"succeed");
}

- (void)requestFailed:(YTKBaseRequest *)request {
    NSLog(@"failed");
}
#pragma mark - ================== 批量发送请求 ==================
/* lzy171103注:
 批量发送请求.
 YTKBatchRequest 类：用于方便地发送批量的网络请求，YTKBatchRequest 是一个容器类，它可以放置多个 YTKRequest 子类，并统一处理这多个网络请求的成功和失败。
 在如下的示例中，我们发送了 4 个批量的请求，并统一处理这 4 个请求同时成功的回调。
 */
/// Send batch request
- (void)sendBatchRequest {
    GetImageApi *a = [[GetImageApi alloc] initWithImageId:@"1.jpg"];
    GetImageApi *b = [[GetImageApi alloc] initWithImageId:@"2.jpg"];
    GetImageApi *c = [[GetImageApi alloc] initWithImageId:@"3.jpg"];
    GetUserInfoApi *d = [[GetUserInfoApi alloc] initWithUserId:@"123"];
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[a, b, c, d]];
    
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        NSLog(@"succeed");
        NSArray *requests = batchRequest.requestArray;
        GetImageApi *a = (GetImageApi *)requests[0];
        GetImageApi *b = (GetImageApi *)requests[1];
        GetImageApi *c = (GetImageApi *)requests[2];
        GetUserInfoApi *user = (GetUserInfoApi *)requests[3];
        // deal with requests result ...
        NSLog(@"%@, %@, %@, %@", a, b, c, user);
    } failure:^(YTKBatchRequest *batchRequest) {
        NSLog(@"failed");
    }];
}
#pragma mark - ================== 链式请求 ==================
/* lzy171103注:
 发送 链式请求，请求之间有依赖顺序.
 用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。
 例如，我们有一个需求，需要用户在注册时，先发送注册的 Api，然后 : * 如果注册成功，再发送读取用户信息的 Api。并且，读取用户信息的 Api 需要使用注册成功返回的用户 id 号。 * 如果注册失败，则不发送读取用户信息的 Api 了。
 以下是具体的代码示例，在示例中，我们在 sendChainRequest 方法中设置好了 Api 相互的依赖，然后。 我们就可以通过 chainRequestFinished 回调来处理所有网络请求都发送成功的逻辑了。如果有任何其中一个网络请求失败了，则会触发 chainRequestFailed 回调。
 */
- (void)sendChainRequest {
    RegisterApi *reg = [[RegisterApi alloc] initWithUsername:@"username" password:@"password"];
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:reg callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        RegisterApi *result = (RegisterApi *)baseRequest;
        NSString *userId = [result userId];
        GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
        [chainRequest addRequest:api callback:nil];
        
    }];
    
    chainReq.delegate = self;
    // start to send request
    [chainReq start];
}

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest {
    // all requests are done
    
}

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest*)request {
    // some one of request is failed
}

#pragma mark - ================== 显示上次缓存的内容 ==================
// 缓存数据加载场景2种
/* lzy171103注:
 在实际开发中，有一些内容可能会加载很慢，我们想先显示上次的内容，等加载成功后，再用最新的内容替换上次的内容。也有时候，由于网络处于断开状态，为了更加友好，我们想显示上次缓存中的内容。这个时候，可以使用 YTKReqeust 的直接加载缓存的高级用法。
 具体的方法是直接使用 YTKRequest 的 - (BOOL)loadCacheWithError: 方法，即可获得上次缓存的内容。当然，你需要把 - (NSInteger)cacheTimeInSeconds 覆盖，返回一个大于等于 0 的值，这样才能开启 YTKRequest 的缓存功能，否则默认情况下，缓存功能是关闭的。
 以下是一个示例，我们在加载用户信息前，先取得上次加载的内容，然后再发送请求，请求成功后再更新界面：
 */
/* lzy171103注:
 加载某个接口的缓存数据。
 场景1：先加载缓存，显示界面。
 然后请求接口获取最新的数据，刷新界面。
 
 前提1 接口对象，设置了缓存时间。在缓存有效期，缓存没有被其他原因判断为无效。
 前提2 之前请求并缓存成功了。
 */
- (void)loadCacheData {
    NSString *userId = @"1";
    GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
    if ([api loadCacheWithError:nil]) {
        NSDictionary *json = [api responseJSONObject];
        NSLog(@"json = %@", json);
        // show cached data
    }

    api.animatingText = @"正在加载";
    api.animatingView = self.view;

    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSLog(@"update ui");
    } failure:^(YTKBaseRequest *request) {
        NSLog(@"failed");
    }];
}
/* lzy171103注:
 缓存加载第二种
 场景2：接口缓存。接口重写父类的 -cacheVersion方法
 
 内部的接口版本可以来自其他接口。
 
 每次都是传入最新的接口版本号。
 
 【api loadCacheWithError:nil】
 方法，会取外部的版本号和 缓存数据元数据的版本号。
 
 如果这个接口版本有更新，元数据验证失败，就发送请求并缓存最新数据
 
 */
- (void)loadCacheData2 {
    NSString *userId = @"1";
    GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
    
    
    if ([api loadCacheWithError:nil]) {//
        NSDictionary *json = [api responseJSONObject];
        NSLog(@"json = %@", json);
        // show cached data
    }else{
        [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSLog(@"update ui");
        } failure:^(YTKBaseRequest *request) {
            NSLog(@"failed");
        }];
        
    }
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
