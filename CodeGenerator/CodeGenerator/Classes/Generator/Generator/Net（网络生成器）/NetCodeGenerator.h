//
//  NetCodeGenerator.h
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/3.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetCodeGenerator : NSObject


// 过滤的参数字典
@property (nonatomic, strong) NSArray *filterParamKeyArray;

/** 请求转换模型名称*/
@property (nonatomic, copy) NSString *jsonObjectName;

#pragma mark - 网络请求生成


/**
 根据url生成

 @param url url
 @return 请求方法
 */
- (NSMutableString *)generateUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
