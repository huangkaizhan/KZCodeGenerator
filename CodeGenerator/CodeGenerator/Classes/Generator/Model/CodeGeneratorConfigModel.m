//
//  CodeGeneratorConfigModel.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2017/12/5.
//  Copyright © 2017年 huangkaizhan. All rights reserved.
//

#import "CodeGeneratorConfigModel.h"
#import "NSString+Category.h"

@implementation CodeGeneratorConfigModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _jsonSuperClassName = @"NSObject";
        _dataSuperClassName = @"NSObject";
        _classPrefixName = @"";
    }
    return self;
}

- (void)setFileName:(NSString *)fileName
{
    fileName = [fileName firstUppercaseString];
    fileName = [self handleFileNamePrefix:fileName];
    _fileName = fileName;
}

- (NSString *)handleFileNamePrefix:(NSString *)fileName
{
    if (!self.classPrefixName.length || [fileName containsString:self.classPrefixName]) {
        return fileName;
    }
    return [NSString stringWithFormat:@"%@%@", self.classPrefixName, fileName];
}

@end
