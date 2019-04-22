//
//  FileManager.h
//  CodeGenerator
//
//  Created by huangkaizhan on 2018/12/1.
//  Copyright © 2018年 huangkaizhan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileManager : NSObject

#pragma mark - 文件及文件夹
// 生成文件到桌面
+ (void)createFileWithHString:(NSMutableString *)hString mString:(NSMutableString *)mString fileName:(NSString *)fileName;


/**
 生成网络请求文件

 @param string 网络请求字符串
 */
+ (void)createNetFileWithString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
