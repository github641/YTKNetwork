//
//  GetUserInfoApi.m
//  YTKNetworkDemo
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "GetUserInfoApi.h"

@implementation GetUserInfoApi {
    NSString *_userId;
}

- (id)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/iphone/users";
}

- (id)requestArgument {
    return @{ @"id": _userId };
}
#pragma mark - ================== 验证服务器返回内容 ==================
/* lzy171103注:
 有些时候，由于服务器的 Bug，会造成服务器返回一些不合法的数据，如果盲目地信任这些数据，可能会造成客户端 Crash。如果加入大量的验证代码，又使得编程体力活增加，费时费力。
 使用 YTKRequest 的验证服务器返回值功能，可以很大程度上节省验证代码的编写时间。
 例如，我们要向网址 http://www.yuantiku.com/iphone/users 发送一个 GET 请求，请求参数是 userId 。我们想获得某一个用户的信息，包括他的昵称和等级，我们需要服务器必须返回昵称（字符串类型）和等级信息（数值类型），则可以覆盖 jsonValidator 方法，实现简单的验证。
 
 以下是更多的 jsonValidator 的示例：
 * 要求返回 String 数组：
 - (id)jsonValidator {
 return @[ [NSString class] ];
 }
 来自猿题库线上环境的一个复杂的例子：
 
 - (id)jsonValidator {
 return @[@{
 @"id": [NSNumber class],
 @"imageId": [NSString class],
 @"time": [NSNumber class],
 @"status": [NSNumber class],
 @"question": @{
 @"id": [NSNumber class],
 @"content": [NSString class],
 @"contentType": [NSNumber class]
 }
 }];
 } 
 */
- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}
#pragma mark - ================== 按时间缓存内容 ==================
/* lzy171103注:
 刚刚我们写了一个 GetUserInfoApi ，这个网络请求是获得用户的一些资料。
 我们想像这样一个场景，假设你在完成一个类似微博的客户端，GetUserInfoApi 用于获得你的某一个好友的资料，因为好友并不会那么频繁地更改昵称，那么短时间内频繁地调用这个接口很可能每次都返回同样的内容，所以我们可以给这个接口加一个缓存。
 在如下示例中，我们通过覆盖 cacheTimeInSeconds 方法，给 GetUserInfoApi 增加了一个 3 分钟的缓存，3 分钟内调用调 Api 的 start 方法，实际上并不会发送真正的请求。
 
 该缓存逻辑对上层是透明的，所以上层可以不用考虑缓存逻辑，每次调用 GetUserInfoApi 的 start 方法即可。GetUserInfoApi 只有在缓存过期时，才会真正地发送网络请求。
 */
- (NSInteger)cacheTimeInSeconds {
    return 60 * 3;
}

@end
