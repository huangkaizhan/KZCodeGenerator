//
//  FileManager.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/1.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

#pragma mark - 文件及文件夹
// 生成文件到桌面
+ (void)createFileWithHString:(NSMutableString *)hString mString:(NSMutableString *)mString fileName:(nonnull NSString *)fileName
{
    if (![fileName containsString:@"Model"]) {
        fileName = [NSString stringWithFormat:@"%@Model", fileName];
    }
    // 生成文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/desktop/CodeGeneratorResult"];
    BOOL isDir = false;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (isDir && isDirExist) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", path, fileName];
        [hString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        filePath = [NSString stringWithFormat:@"%@/%@.m", path, fileName];
        [mString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        if ([fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil]) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", path, fileName];
            [hString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            filePath = [NSString stringWithFormat:@"%@/%@.m", path, fileName];
            [mString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"生成可能成功，请前往桌面的CodeGeneratorResult文件夹查看";
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
}

// 生成网络请求文件
+ (void)createNetFileWithString:(NSString *)string
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/desktop/CodeGeneratorResult"];
    BOOL isDir = false;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (isDir && isDirExist) {
        NSString *filePath = [NSString stringWithFormat:@"%@/NetFunction.h", path];
        [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        if ([fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil]) {
            NSString *filePath = [NSString stringWithFormat:@"%@/NetFunction.h", path];
            [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}
@end
