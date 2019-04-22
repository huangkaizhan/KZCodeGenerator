//
//  CodeGenerator.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2017/12/5.
//  Copyright © 2017年 huangkaizhan. All rights reserved.
//

#import "ModelGenerator.h"
#import "FileManager.h"
#import "NSString+Category.h"
#import "NSDate+Category_lib.h"

@interface ModelGenerator()
//
@property (nonatomic, strong) NSMutableDictionary *tempDict;

// mjextention储值字典
@property (nonatomic, strong) NSMutableDictionary *mjexteitonDict;

/** 模型字典*/
@property (nonatomic, strong) NSMutableDictionary *modelDict;

/** 关键字替换字典*/
@property (nonatomic, strong) NSDictionary *keywordDict;
@end


@implementation ModelGenerator


/**
 根据字符串生成
 
 @param json json字符串
 */
- (NSMutableString *)generateWithJSON:(NSString *)json
{
    // 使用json内容生成
    NSDictionary *dict = [json toJsonDict];
    if (!dict) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"JSON格式错误";
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return [NSMutableString stringWithString:@"JSON格式错误"];
    }
    NSMutableString *string = [self generateWithDict:dict];
    return string;
}

/**
 根据字典生成
 
 @param dict json字典
 */
- (NSMutableString *)generateWithDict:(NSDictionary *)dict
{
    [self.modelDict removeAllObjects];
    // .h
    NSMutableString *hString = [NSMutableString string];
    // .m
    NSMutableString *mString = [NSMutableString string];
    self.tempDict = [NSMutableDictionary dictionary];
    // mj
    self.mjexteitonDict = [NSMutableDictionary dictionary];
    // 生成model
    [self handleDefaultDictionaryValue:dict key:@"" hString:hString mString:mString];
    // 生成头注释
    [self generateHeaderWithHString:hString mString:mString];
    // 生成文件到桌面
    [FileManager createFileWithHString:hString mString:mString fileName:self.configModel.fileName];
    return hString;
}

// 默认全部生成，子类可继承
- (void)handleDefaultDictionaryValue:(NSDictionary *)dict key:(NSString *)key hString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
    [self handleDictionaryValue:dict key:@"" hString:hString mString:mString];
}

// 默认全部生成
- (void)handleDictionaryValue:(NSDictionary *)dict key:(NSString *)key hString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
    if (key.length) {
        // 这是大模型嵌入小模型的开头
        NSString *modelName = [self modelNameWithString:key];
        [hString insertString:[NSString stringWithFormat:@"@class %@;\r\n", modelName] atIndex:0];
        [hString appendFormat:@"\r\n\r\n@interface %@ : %@\r\n\r\n",modelName, self.configModel.dataSuperClassName];
        [mString appendFormat:@"\r\n\r\n@implementation %@\r\n\r\n",modelName];
        // 还原继承
        self.configModel.jsonSuperClassName = @"NSObject";
        self.configModel.dataSuperClassName = @"NSObject";
    } else {
        // 总开头
        [hString appendFormat:@"\r\n\r\n@interface %@ : %@\r\n\r\n", self.configModel.fileName, self.configModel.jsonSuperClassName];
        [mString appendFormat:@"\r\n#import \"%@.h\"\r\n", self.configModel.fileName];
        [mString appendFormat:@"\r\n\r\n@implementation %@\r\n\r\n", self.configModel.fileName];
    }
    NSArray *keyArray = [dict allKeys];
    NSMutableDictionary *mjReplaceKeyDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *mjReplaceKeyArrayDict = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < keyArray.count; i++) {
        NSString *key = keyArray[i];
        id value = dict[key];
        // 驼峰转换
        if (self.configModel.hump) {
            NSString *newKey = [key toHump];
            if (![newKey isEqualToString:key]) {
                // 有转换，这时需要存储key为mj转换用
                [mjReplaceKeyDict setObject:newKey forKey:key];
                key = newKey;
            }
        }
        // 关键字转换
        for (NSString *keyword in self.keywordDict.allKeys) {
            if ([key isEqualToString:keyword]) {
                key = self.keywordDict[keyword];
                // 有转换，这时需要存储key为mj转换用
                [mjReplaceKeyDict setObject:key forKey:keyword];
                break;
            }
        }
        if (value) {
            // 字符串
            if ([value isKindOfClass:[NSString class]]) {
                [hString appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, copy) NSString *%@;\r\n",key];
            }
            // 数值类型
            else if ([value isKindOfClass:[NSNumber class]]) {
                [self handleNumberValue:value key:key string:hString];
            }
            // 数组类型
            else if ([value isKindOfClass:[NSArray class]]) {
                [self handleArrayValue:value key:key hString:hString mString:mString mjReplaceKeyArrayDict:mjReplaceKeyArrayDict];
            }
            // 字典类型
            else if ([value isKindOfClass:[NSDictionary class]]) {
                [self handleDictValue:value key:key string:hString];
            }
            // 识别不出类型，如null等
            else {
                [hString appendString:@"#warning 未知类型\r\n"];
                [hString appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, strong) id %@;\r\n",key];
            }
        }
    }
    if (key.length) {
        [self.tempDict removeObjectForKey:key];
    }
    // .h结束
    [hString appendFormat:@"\r\n@end\r\n"];
    // .m结束
    // 处理.m文件中的mj转换
    [self handleMJExtensionWithDict:mjReplaceKeyDict arrayDict:mjReplaceKeyArrayDict mString:mString];
    [mString appendFormat:@"\r\n@end\r\n"];
    if (self.tempDict.count) {
        NSString *firstKey = self.tempDict.allKeys.firstObject;
        NSDictionary *firstValue = self.tempDict[firstKey];
        // 递归字典生成对象
        [self handleDictionaryValue:firstValue key:firstKey hString:hString mString:mString];
    }
}

// 处理字典类型
- (void)handleDictValue:(NSString *)value key:(NSString *)key string:(NSMutableString *)stringM
{
    NSString *modelName = [self modelNameWithString:key];
    [stringM appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, strong) %@ *%@;\r\n",modelName, key];
    [self.tempDict setObject:value forKey:key];
}

// 处理数值类型
- (void)handleNumberValue:(NSNumber *)value key:(NSString *)key string:(NSMutableString *)stringM
{
    // char字符串
    if (strcmp([value objCType], @encode(char)) == 0 || strcmp([value objCType], @encode(unsigned char)) == 0) {
        [stringM appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, copy) NSString *%@;\r\n",key];
    }
    // 浮点类型
    else if (strcmp([value objCType], @encode(float)) == 0 || strcmp([value objCType], @encode(double)) == 0) {
        [stringM appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, assign) CGFloat %@;\r\n",key];
    }
    // 布尔类型
    else if (strcmp([value objCType], @encode(BOOL)) == 0) {
        [stringM appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, assign) BOOL %@;\r\n",key];
    }
    // 整数类型
    else {
        // 如果整数值太大，比如时间戳,那么还是转为字符串类型
        if ([value integerValue] > 999999999) {
            [stringM appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, copy) NSString *%@;\r\n",key];
        } else {
            [stringM appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, assign) NSInteger %@;\r\n",key];
        }
    }
}

// 处理数组类型类型
- (void)handleArrayValue:(NSArray *)array key:(NSString *)key hString:(NSMutableString *)hString mString:(NSMutableString *)mString mjReplaceKeyArrayDict:(NSMutableDictionary *)mjReplaceKeyArrayDict
{
    id value = array.firstObject;
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSString *modelName = [self modelNameWithString:key];
        [hString appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, strong) NSArray <%@ *>*%@;\r\n", modelName, key];
        // 保存mj的转换数组，比如数组里面是什么对象类型
        [mjReplaceKeyArrayDict setObject:key forKey:modelName];
        [self.tempDict setObject:value forKey:key];
        [self.modelDict setObject:modelName forKey:key];
    } else {
        [hString appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, strong) NSArray *%@;\r\n",key];
    }
}

// 处理.m文件中的mj转换
- (void)handleMJExtensionWithDict:(NSMutableDictionary *)mjReplaceKeyDict arrayDict:(NSMutableDictionary *)mjReplaceKeyArrayDict mString:(NSMutableString *)mString
{
    // 这是是mj属性转换
    if (mjReplaceKeyDict.count) {
        [mString appendFormat:@"\r\n+ (NSDictionary *)replacedKeyFromPropertyName\r\n{\r\n    return @{"];
        for (NSString *mjKey in mjReplaceKeyDict.allKeys) {
            NSString *mjValue = mjReplaceKeyDict[mjKey];
            [mString appendFormat:@"\r\n              @\"%@\" : @\"%@\",", mjValue, mjKey];
        }
        [mString appendFormat:@"};\r\n}\r\n"];
    }
    // 这是mj数组对象说明
    if (mjReplaceKeyArrayDict.count) {
        [mString appendFormat:@"\r\n+ (NSDictionary *)objectClassInArray\r\n{\r\n    return @{"];
        for (NSString *mjKey in mjReplaceKeyArrayDict.allKeys) {
            NSString *mjValue = mjReplaceKeyArrayDict[mjKey];
            [mString appendFormat:@"\r\n              @\"%@\" : [%@ class],", mjValue, mjKey];
        }
        [mString appendFormat:@"};\r\n}\r\n"];
    }
}

- (NSString *)modelNameWithString:(NSString *)string
{
    return [self modelNameWithString:string modelString:@"Model"];;
}

- (NSString *)modelNameWithString:(NSString *)string modelString:(NSString *)modelString
{
    if ([string containsString:modelString]) {
        if (![string containsString:self.configModel.classPrefixName]) {
            return [NSString stringWithFormat:@"%@%@", self.configModel.classPrefixName, string];
        }
        return string;
    }
    NSString *name = [string substringToIndex:1];
    name = [name uppercaseString];
    name = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:name];
    if (![string containsString:self.configModel.classPrefixName]) {
        name = [NSString stringWithFormat:@"%@%@%@", self.configModel.classPrefixName, name, modelString];
    } else {
        name = [NSString stringWithFormat:@"%@%@", name, modelString];
    }
    return name;
}

// 生成头部注释
- (void)generateHeaderWithHString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
    NSString *dateString = [[NSDate date] formatYearMonthDayChinese_lib];
    NSString *yearString = [[NSDate date] formatYear_lib];
    [hString insertString:@"\r\n\r\n#import <Foundation/Foundation.h>\r\n" atIndex:0];
    NSString *msgString = [NSString stringWithFormat:@"//\r\n//  %@.h\r\n//  %@\r\n//\r\n//  Created by %@ on %@.\r\n//  Copyright © %@年 %@. All rights reserved.\r\n//  url : %@\r\n//  ", self.configModel.fileName, self.configModel.fileName, dateString, self.configModel.authorName, self.configModel.authorName, yearString, self.configModel.urlString];
    [hString insertString:msgString atIndex:0];
    msgString = [NSString stringWithFormat:@"//\r\n//  %@.h\r\n//  %@\r\n//\r\n//  Created by %@ on %@.\r\n//  Copyright © %@年 %@. All rights reserved.\r\n//  ", self.configModel.fileName, self.configModel.fileName, dateString, self.configModel.authorName, yearString, self.configModel.authorName];
    [mString insertString:msgString atIndex:0];
}

#pragma mark - 懒加载
- (NSMutableDictionary *)modelDict
{
    if (!_modelDict) {
        _modelDict = [NSMutableDictionary dictionary];
    }
    return _modelDict;
}

- (NSDictionary *)keywordDict
{
    if (!_keywordDict) {
        _keywordDict = @{ @"id" : @"Id"};
    }
    return _keywordDict;
}
@end
