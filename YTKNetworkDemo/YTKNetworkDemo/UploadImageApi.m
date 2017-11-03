//
//  UploadImageApi.m
//  Solar
//
//  Created by tangqiao on 8/7/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "UploadImageApi.h"
#import "AFNetworking.h"

@implementation UploadImageApi {
    UIImage *_image;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl {
    return @"/iphone/image/upload";
}
/* lzy171103注:
 我们可以通过覆盖 constructingBodyBlock 方法，来方便地上传图片等附件，如下是一个示例：
 
 通过如上代码，我们创建了一个上传图片，然后获得服务器返回的 imageId 的网络请求 Api。
 */
- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"image";
        NSString *formKey = @"image";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

- (id)jsonValidator {
    return @{ @"imageId": [NSString class] };
}

- (NSString *)responseImageId {
    NSDictionary *dict = self.responseJSONObject;
    return dict[@"imageId"];
}

@end
