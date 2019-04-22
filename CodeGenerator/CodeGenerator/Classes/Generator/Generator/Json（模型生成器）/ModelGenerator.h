//
//  CodeGenerator.h
//  CodeGenerator
//
//  Created by huangkaizhan on 2017/12/5.
//  Copyright © 2017年 huangkaizhan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "CodeGeneratorConfigModel.h"

@interface ModelGenerator : NSObject

// 配置模型
@property (nonatomic, strong) CodeGeneratorConfigModel *configModel;

// 窗口
@property (nonatomic, weak) NSWindow *window;

#pragma mark - 字典对象生成
/**
 根据字典生成

 @param dict json字典
 */
- (NSMutableString *)generateWithDict:(NSDictionary *)dict;

/**
 根据字符串生成

 @param json json字符串
 */
- (NSMutableString *)generateWithJSON:(NSString *)json;


#pragma mark - 子类用

- (NSString *)modelNameWithString:(NSString *)string;
- (NSString *)modelNameWithString:(NSString *)string modelString:(NSString *)modelString;
// 处理字典类型
- (void)handleDictValue:(NSString *)value key:(NSString *)key string:(NSMutableString *)stringM;
- (void)handleDefaultDictionaryValue:(NSDictionary *)dict key:(NSString *)key hString:(NSMutableString *)hString mString:(NSMutableString *)mString;
/**
 生成model，给子类用

 @param dict 字典
 @param key 健
 */
- (void)handleDictionaryValue:(NSDictionary *)dict key:(NSString *)key hString:(NSMutableString *)hString mString:(NSMutableString *)mString;


@end
