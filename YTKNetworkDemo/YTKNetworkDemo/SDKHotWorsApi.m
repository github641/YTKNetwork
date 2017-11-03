//
//  SDKHotWorsApi.m
//  YTKNetworkDemo
//
//  Created by admin on 2017/11/3.
//  Copyright © 2017年 yuantiku.com. All rights reserved.
//

#import "SDKHotWorsApi.h"

@implementation SDKHotWorsApi

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}
- (NSMutableDictionary *)defaultParametersMutableDic{
    return [NSMutableDictionary new];
}
- (NSDictionary *)addTokenWithFullParamDic:(NSDictionary *)dic{
    // token计算
    return dic;
}
- (id)requestArgument {
    //
    //    return @{
    //             @"appID": [DkSearchAd sharedInstance].appID,
    //             @"type": @"sdk"
    //             };
    
    NSMutableDictionary *dic = [self defaultParametersMutableDic];
    [dic setObject:@"appID" forKey:@"pid"];
    [dic setObject:@"userID" forKey:@"userid"];
    
    [dic setObject:@"sdk" forKey:@"type"];
    return [self addTokenWithFullParamDic:dic];
}
- (NSString *)requestUrl {
    // “ http://www.yuantiku.com ” 在 YTK.NetworkConfig 中设置，这里只填除去域名剩余的网址信息
        return @"http://192.168.1.23:3000/updateSdkHotWords";
    
}
//- (id)cacheFileNameFilterForRequestArgument:(id)argument{
//    return @[@"cid",@"lat",@"lng",@"isw",@"lip",@"sim",@"mac",@"ap",@"mn",@"sv",@"is_jb",@"idfv",@"idfa",@"uuid_k",@"wifi_BSSID",@"sc_b",@"ra_net",@"ui_net",@"ct_net",@"ct_ca",@"ct_cc",@"ct_iso",@"ct_voip",@"lc_l",@"lc_c",@"apps_sys",@"sys_ft",@"sys_bt",@"sys_lt"];
//}
- (id)cacheFileNameFilterForRequestArgument:(id)argument{
    return @{@"type": @"sdk"};
}
#pragma mark - ================== 验证服务器返回内容 ==================
/*
 有些时候，由于服务器的 Bug，会造成服务器返回一些不合法的数据，如果盲目地信任这些数据，可能会造成客户端 Crash。如果加入大量的验证代码，又使得编程体力活增加，费时费力。
 使用 YTKRequest 的验证服务器返回值功能，可以很大程度上节省验证代码的编写时间。
 例如，我们要向网址 http://www.yuantiku.com/iphone/users 发送一个 GET 请求，请求参数是 userId 。我们想获得某一个用户的信息，包括他的昵称和等级，我们需要服务器必须返回昵称（字符串类型）和等级信息（数值类型），则可以覆盖 jsonValidator 方法，实现简单的验证。
 */
//- (id)jsonValidator {
//    return @[@{
//                 @"id": [NSNumber class],
//                 @"imageId": [NSString class],
//                 @"time": [NSNumber class],
//                 @"status": [NSNumber class],
//                 @"question": @{
//                         @"id": [NSNumber class],
//                         @"content": [NSString class],
//                         @"contentType": [NSNumber class]
//                         }
//                 }];
//}

/*
 如果要使用 CDN 地址，只需要覆盖 YTKRequest 类的 - (BOOL)useCDN; 方法。
 例如我们有一个取图片的接口，地址是 http://fen.bi/image/imageId ，则我们可以这么写代码 :
 */
//- (BOOL)useCDN {
//    return YES;
//}

/*
 按时间缓存内容
 
 刚刚我们写了一个 GetUserInfoApi ，这个网络请求是获得用户的一些资料。
 我们想像这样一个场景，假设你在完成一个类似微博的客户端，GetUserInfoApi 用于获得你的某一个好友的资料，因为好友并不会那么频繁地更改昵称，那么短时间内频繁地调用这个接口很可能每次都返回同样的内容，所以我们可以给这个接口加一个缓存。
 在如下示例中，我们通过覆盖 cacheTimeInSeconds 方法，给 GetUserInfoApi 增加了一个 3 分钟的缓存，3 分钟内调用调 Api 的 start 方法，实际上并不会发送真正的请求。
 该缓存逻辑对上层是透明的，所以上层可以不用考虑缓存逻辑，每次调用 GetUserInfoApi 的 start 方法即可。GetUserInfoApi 只有在缓存过期时，才会真正地发送网络请求。
 */
- (NSInteger)cacheTimeInSeconds {
    // 60*60*24*7 一周
    return 604800;
}

//- (NSString *)cacheVersion{
//    //    DebugLog(@"sdkHotWordsVersion.floatValue:%f",[DksInitModel sharedInstance].data.base.sdkHotWordsVersion.floatValue);
//
//    return [DksInitModel sharedInstance].data.base.sdkHotWordsVersion;
//}
// 见文档：CacheVersion改为字符串
- (long long)cacheVersion{
    
    return 1111;// 其他比这个更前的接口，每次必请求的接口，返回的，这个接口的最新版本号。
}
#pragma mark - ================== 定制网络请求的 HeaderField ==================
/* lzy171103注:
 通过覆盖 requestHeaderFieldValueDictionary 方法返回一个 dictionary 对象来自定义请求的 HeaderField，返回的 dictionary，其 key 即为 HeaderField 的 key，value 为 HeaderField 的 Value，需要注意的是 key 和 value 都必须为 string 对象。
 */
- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary{
    
    return [NSDictionary new];
}

#pragma mark - ================== 定制 buildCustomUrlRequest ==================
/* lzy171103注:
 过覆盖 buildCustomUrlRequest 方法，返回一个 NSUrlRequest 对象来达到完全自定义请求的需求。该方法定义在 YTKBaseRequest 类，如下：
 // 构建自定义的 UrlRequest，
 // 若这个方法返回非 nil 对象，会忽略 requestUrl, requestArgument, requestMethod, requestSerializerType,requestHeaderFieldValueDictionary
 如注释所言，如果构建自定义的 request，会忽略其他的一切自定义 request 的方法，例如 requestUrl, requestArgument, requestMethod, requestSerializerType,requestHeaderFieldValueDictionary 等等。一个上传 gzippingData 的示例如下：
 */
- (NSURLRequest *)buildCustomUrlRequest {
//    NSData *rawData = [[_events jsonString] dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *gzippingData = [NSData gtm_dataByGzippingData:rawData];
    
    NSData *rawData = [@"" dataUsingEncoding:NSUTF8StringEncoding];

    NSData *gzippingData = [NSData new];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setHTTPBody:gzippingData];
    return request;
}
@end
