//
//  GetImageApi.m
//  YTKNetworkDemo
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "GetImageApi.h"

@implementation GetImageApi {
    NSString *_imageId;
}

- (id)initWithImageId:(NSString *)imageId {
    self = [super init];
    if (self) {
        _imageId = imageId;
    }
    return self;
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"/iphone/images/%@", _imageId];
}
#pragma mark - ================== 使用 CDN 地址 ==================
/* lzy171103注:
 如果要使用 CDN 地址，只需要覆盖 YTKRequest 类的 - (BOOL)useCDN; 方法。
 例如我们有一个取图片的接口，地址是 http://fen.bi/image/imageId ，则我们可以这么写代码 :
 */
- (BOOL)useCDN {
    return YES;
}

#pragma mark - ================== 断点续传 ==================
/* lzy171103注:
 要启动断点续传功能，只需要覆盖 resumableDownloadPath 方法，指定断点续传时文件的存储路径即可，文件会被自动保存到此路径。如下代码将刚刚的取图片的接口改造成了支持断点续传：
 */
- (NSString *)resumableDownloadPath {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:_imageId];
    return filePath;
}

@end
