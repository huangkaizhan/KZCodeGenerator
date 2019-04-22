//
//  NSString+Category.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/3.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

- (NSString *)firstUppercaseString
{
    if (!self.length) {
        return self;
    }
    NSString *firstStr = [[self substringToIndex:1] uppercaseString];
    return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstStr];
}

- (NSDictionary *)toJsonDict
{
    NSData *JSONData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    return dict;
}

// 将含有_转为驼峰
- (NSString *)toHump
{
    NSRange range =  [self rangeOfString:@"_"];
    if (range.location == NSNotFound) {
        return self;
    }
    NSString *upString = [[self substringWithRange:NSMakeRange(range.location + 1, 1)] uppercaseString];
    NSString *newString = [self stringByReplacingCharactersInRange:NSMakeRange(range.location + 1, 1) withString:upString];
    newString = [newString stringByReplacingCharactersInRange:range withString:@""];
    return [newString toHump];
}
@end
