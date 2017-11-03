//
//  UploadImageApi.h
//  Solar
//
//  Created by tangqiao on 8/7/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//
/* lzy171103注:
 图片上传示例
 */
#import "YTKRequest.h"
#import <UIKit/UIKit.h>

@interface UploadImageApi : YTKRequest

- (id)initWithImage:(UIImage *)image;

- (NSString *)responseImageId;

@end
