//
//  PHCodeGenerator.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/3.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import "PHModelGenerator.h"

@implementation PHModelGenerator

- (void)setConfigModel:(CodeGeneratorConfigModel *)configModel
{
    if (configModel) {
        configModel.jsonSuperClassName = @"PHNewAPIBaseModel";
        configModel.dataSuperClassName = @"PHAPIBaseDataModel";
        configModel.classPrefixName = @"PH";
    }
    [super setConfigModel:configModel];
}

// 指定app生成
- (void)handleDefaultDictionaryValue:(NSDictionary *)dict key:(NSString *)key hString:(NSMutableString *)hString mString:(NSMutableString *)mString
{
    // 转换为小字典
    NSString *dataKey = @"data";
    NSDictionary *dataDict = dict[dataKey];
    if (dataDict.count) {
        // 最外围模型
        NSString *jsonModelName = [self modelNameWithString:self.configModel.fileName modelString:@"JsonModel"];
        NSString *modelName = [self modelNameWithString:self.configModel.fileName];
        [hString appendFormat:@"\r\n\r\n@interface %@ : %@\r\n\r\n",jsonModelName, self.configModel.jsonSuperClassName];
        // data数据
        [hString appendFormat:@"/** <#zhushi#>*/\r\n@property (nonatomic, strong) %@ *data;\r\n",modelName];
        // .h结束
        [hString appendFormat:@"\r\n@end\r\n"];
        
        // m开始引入头文件
        [mString appendFormat:@"\r\n#import \"%@.h\"\r\n", self.configModel.fileName];
        // m生成json
        [mString appendFormat:@"\r\n\r\n@implementation %@\r\n\r\n", jsonModelName];
        [mString appendFormat:@"\r\n@end\r\n"];
        
        // 生成
        [self handleDictionaryValue:dataDict key:self.configModel.fileName hString:hString mString:mString];
    }
}

// 处理字典类型
- (void)handleDictValue:(NSString *)value key:(NSString *)key string:(NSMutableString *)stringM
{
    if ([key isEqualToString:@"reportEvent"]) {
        // 处理上报字段，不用重复生成model
        [stringM appendString:@"/** 上报*/\r\n@property (nonatomic, strong) PHPreciseRecommendationReportEvent *reportEvent;\r\n"];
    } else {
        [super handleDictValue:value key:key string:stringM];
    }
}


@end
