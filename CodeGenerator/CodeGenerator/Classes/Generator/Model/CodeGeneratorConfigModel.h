//
//  CodeGeneratorConfigModel.h
//  CodeGenerator
//
//  Created by huangkaizhan on 2017/12/5.
//  Copyright © 2017年 huangkaizhan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    AppTypeDefault,  // 默认都不选
    AppTypeMaMaWang, // 妈妈网
    AppTypePregnant, // 孕育管家
}AppType;

@interface CodeGeneratorConfigModel : NSObject

/**
 是否驼峰
 */
@property (nonatomic, assign) BOOL hump;

/**
 是否使用MJExtesion
 */
@property (nonatomic, assign) BOOL userMJExtension;

/**
 app类型
 */
@property (nonatomic, assign) AppType appType;


/** json继承类名，最外字典*/
@property (nonatomic, copy) NSString *jsonSuperClassName;

/**
 data继承类名
 */
@property (nonatomic, copy) NSString *dataSuperClassName;

/**
 类名前缀
 */
@property (nonatomic, copy) NSString *classPrefixName;

/**
 文件名
 */
@property (nonatomic, copy) NSString *fileName;

/**
 作者名
 */
@property (nonatomic, copy) NSString *authorName;

/**
 url链接
 */
@property (nonatomic, copy) NSString *urlString;
@end
