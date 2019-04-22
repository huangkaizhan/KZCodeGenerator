//
//  NetCodeGenerator.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/3.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import "NetCodeGenerator.h"
#import "FileManager.h"

@interface NetCodeGenerator()

@end

@implementation NetCodeGenerator

// 根据url生成
- (NSMutableString *)generateUrl:(NSString *)url
{
    if (!url.length) {
        return [NSMutableString string];
    }
    NSDictionary *dict = [self getURLParameters:url];
    NSRange questionRange = [url rangeOfString:@"?"];
    NSString *newUrl = [url substringWithRange:NSMakeRange(0, questionRange.location)];
    NSRange range = [newUrl rangeOfString:@"/" options:NSBackwardsSearch];
    newUrl = [newUrl substringFromIndex:range.location];
    newUrl = [newUrl stringByReplacingOccurrencesOfString:@"/" withString:@""];
    newUrl = [newUrl stringByReplacingOccurrencesOfString:@".php" withString:@""];
    newUrl = [newUrl toHump];
    // 妈妈网生成
    NSMutableString *hFuncString = [NSMutableString string];
    NSMutableString *mFuncString = [NSMutableString string];
    [self generateUrl:newUrl hFuncString:hFuncString mFuncString:mFuncString dict:dict];
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@\r\n\r\n\r\n\r\n%@", hFuncString, mFuncString];
    // 生成网络请求文件
    [FileManager createNetFileWithString:urlString];
    return urlString;
}



// 生成url方法
- (void)generateUrl:(NSString *)url hFuncString:(NSMutableString *)hFuncString mFuncString:(NSMutableString *)mFuncString dict:(NSDictionary *)dict
{
    NSAssert(NO, @"子类重写");
}

// 截取URL中的参数 : 网上抄的，懒得写正则
- (NSMutableDictionary *)getURLParameters:(NSString *)urlStr {
    
    // 查找参数
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}

#pragma mark - 懒加载
- (NSArray *)filterParamKeyArray
{
    if (!_filterParamKeyArray) {
        _filterParamKeyArray = @[
                                 @"hash",
                                 @"version",
                                 @"source",
                                 @"appkey",
                                 @"t",
                                 @"sign",
                                 @"statistics_latitude",
                                 @"statistics_network_type",
                                 @"statistics_device_model",
                                 @"statistics_longitude",
                                 @"statistics_carrier",
                                 @"statistics_ios_idfa",
                                 @"device_id",
                                 @"statistics_app_source",
                                 @"statistics_app_channel",
                                 @"statistics_os_version",
                                 ];
    }
    return _filterParamKeyArray;
}
@end
