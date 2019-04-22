//
//  BMModelGenerator.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/3.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import "BMModelGenerator.h"

@implementation BMModelGenerator

- (void)setConfigModel:(CodeGeneratorConfigModel *)configModel
{
    if (configModel) {
        configModel.jsonSuperClassName = @"MABaseModel";
        configModel.dataSuperClassName = @"NSObject";
        configModel.classPrefixName = @"BM";
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
        if ([modelName isEqualToString:@"BMJsonModel"]) {
            modelName = @"BMJsonDataModel";
        }
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

@end
