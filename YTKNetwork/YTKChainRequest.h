//
//  YTKChainRequest.h
//
//  Copyright (c) 2012-2016 YTKNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
/* lzy注170713：
 链式请求，也就是请求之间互相依赖，串行发出。和批量请求相似的，通过一个YTKBatchRequestAgent(数组)来管理这些依赖的请求。内部通过_nextRequestIndex来索引正在进行和下一个将要处理的请求，每次上一个请求成功回调回来，才开始下一个链式的请求
 */
/* lzy注170717：
 用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。
 
 例如，我们有一个需求，需要用户在注册时，先发送注册的 Api，
 然后 : * 如果注册成功，再发送读取用户信息的 Api。并且，读取用户信息的 Api 需要使用注册成功返回的用户 id 号。
 * 如果注册失败，则不发送读取用户信息的 Api 了。
 
 以下是具体的代码示例，在示例中，我们在 sendChainRequest 方法中设置好了 Api 相互的依赖，然后。 我们就可以通过 chainRequestFinished 回调来处理所有网络请求都发送成功的逻辑了。如果有任何其中一个网络请求失败了，则会触发 chainRequestFailed 回调。
 
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
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YTKChainRequest;
@class YTKBaseRequest;
@protocol YTKRequestAccessory;

///  The YTKChainRequestDelegate protocol defines several optional methods you can use
///  to receive network-related messages. All the delegate methods will be called
///  on the main queue. Note the delegate methods will be called when all the requests
///  of chain request finishes.
@protocol YTKChainRequestDelegate <NSObject>

@optional
///  Tell the delegate that the chain request has finished successfully.
///
///  @param chainRequest The corresponding chain request.
- (void)chainRequestFinished:(YTKChainRequest *)chainRequest;

///  Tell the delegate that the chain request has failed.
///
///  @param chainRequest The corresponding chain request.
///  @param request      First failed request that causes the whole request to fail.
- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest*)request;

@end

/* lzy注170717：
 声明链式请求的回调block
 */
typedef void (^YTKChainCallback)(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest);

///  YTKBatchRequest can be used to chain several YTKRequest so that one will only starts after another finishes.
///  Note that when used inside YTKChainRequest, a single YTKRequest will have its own callback and delegate
///  cleared, in favor of the batch request callback.

@interface YTKChainRequest : NSObject

///  All the requests are stored in this array.
- (NSArray<YTKBaseRequest *> *)requestArray;

///  The delegate object of the chain request. Default is nil.
@property (nonatomic, weak, nullable) id<YTKChainRequestDelegate> delegate;

///  This can be used to add several accossories object. Note if you use `addAccessory` to add acceesory
///  this array will be automatically created. Default is nil.
@property (nonatomic, strong, nullable) NSMutableArray<id<YTKRequestAccessory>> *requestAccessories;

///  Convenience method to add request accessory. See also `requestAccessories`.
- (void)addAccessory:(id<YTKRequestAccessory>)accessory;

///  Start the chain request, adding first request in the chain to request queue.
- (void)start;

///  Stop the chain request. Remaining request in chain will be cancelled.
- (void)stop;

///  Add request to request chain.
///
///  @param request  The request to be chained.
///  @param callback The finish callback
- (void)addRequest:(YTKBaseRequest *)request callback:(nullable YTKChainCallback)callback;

@end

NS_ASSUME_NONNULL_END
