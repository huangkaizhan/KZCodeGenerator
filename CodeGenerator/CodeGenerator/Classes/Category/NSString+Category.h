//
//  NSString+Category.h
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/3.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Category)


/**
 首字母大写

 @return 新字符串
 */
- (NSString *)firstUppercaseString;


/**
 将字符串转为json字典

 @return 字典
 */
- (NSDictionary *)toJsonDict;


/**
 将含有_转为驼峰

 @return 驼峰字符串
 */
- (NSString *)toHump;
@end

NS_ASSUME_NONNULL_END
