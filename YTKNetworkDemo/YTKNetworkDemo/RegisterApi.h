//
//  RegisterApi.h
//  Solar
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "YTKRequest.h"
/* lzy171103注:
 一般接口，出了全局参数之外的 普通请求参数
 */
@interface RegisterApi : YTKRequest

- (id)initWithUsername:(NSString *)username password:(NSString *)password;


/**
 返回数据中的userId字段的数据
 */
- (NSString *)userId;

@end
