//
//  ViewController.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2017/12/4.
//  Copyright © 2017年 huangkaizhan. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "ModelGenerator.h"
#import "PHModelGenerator.h"
#import "BMModelGenerator.h"
#import "BMNetCodeGenerator.h"
#import "PHNetCodeGenerator.h"

@interface ViewController()
#pragma mark - 普通
// 代码生成器
@property (nonatomic, strong) ModelGenerator *generator;
#pragma mark - 轻聊
/** 妈妈网轻聊模型生成器*/
@property (nonatomic, strong) BMModelGenerator *bmModelGenerator;
/** 妈妈网轻聊网络生成器*/
@property (nonatomic, strong) BMNetCodeGenerator *bmNetGenerator;
#pragma mark - 孕育
/** 妈妈网孕育模型生成器*/
@property (nonatomic, strong) PHModelGenerator *phModelGenerator;
/** 妈妈网孕育网络生成器*/
@property (nonatomic, strong) PHNetCodeGenerator *phNetGenerator;

@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;
@property (unsafe_unretained) IBOutlet NSTextView *resultTextView;
@property (unsafe_unretained) IBOutlet NSTextView *urlTextView;

@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *fileNameTextField;
@property (weak) IBOutlet NSButton *humpButton;
@property (weak) IBOutlet NSButton *mjExtentionButton;
@property (weak) IBOutlet NSTextField *prefixTextField;
@end

static NSString *Key_Author_Name_UD = @"Key_Author_Name_UD";
static NSString *Key_App_Name_UD = @"Key_App_Name_UD";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:Key_Author_Name_UD];
    if (name.length) {
        self.nameTextField.stringValue = name;
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)generate:(id)sender
{
    if (!self.jsonTextView.textStorage.string.length && !self.urlTextField.stringValue.length) {
        return;
    }
    if (!self.fileNameTextField.stringValue.length) {
        [self.fileNameTextField becomeFirstResponder];
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/desktop/CodeGeneratorResult"];
    [fileManager removeItemAtPath:path error:nil];
    // 配置
    CodeGeneratorConfigModel *config = [[CodeGeneratorConfigModel alloc] init];
    config.authorName = self.nameTextField.stringValue;
    config.urlString = self.urlTextField.stringValue;
    config.fileName = self.fileNameTextField.stringValue;
    config.hump = self.humpButton.state;
    config.userMJExtension = self.mjExtentionButton.state;
    config.classPrefixName = self.prefixTextField.stringValue;
    switch (config.appType) {
        case AppTypeMaMaWang:
            self.generator = self.bmModelGenerator;
            break;
        case AppTypePregnant:
            self.generator = self.phModelGenerator;
            break;
        default:
            _generator = nil;
            break;
    }
    self.generator.configModel = config;
    
    // 缓存
    [[NSUserDefaults standardUserDefaults] setObject:config.authorName forKey:Key_Author_Name_UD];
    [[NSUserDefaults standardUserDefaults] setInteger:config.appType forKey:Key_App_Name_UD];
    // 生成
    if (self.urlTextField.stringValue.length) {
        __weak typeof(self) weakSelf = self;
        // 1.使用url生成
        AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
        [sessionManager GET:self.urlTextField.stringValue parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // 使用字典生成
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[weakSelf.generator generateWithDict:responseObject]];
            [weakSelf.resultTextView.textStorage setAttributedString:attrString];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"请求出错";
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        }];
        
        //2.url请求生成，自定义
        switch (config.appType) {
            case AppTypeMaMaWang:
            {
                NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[self.bmNetGenerator generateUrl:config.urlString]];
                [weakSelf.urlTextView.textStorage setAttributedString:attrString];
            }
                break;
            case AppTypePregnant:
            {
                NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[self.phNetGenerator generateUrl:config.urlString]];
                [weakSelf.urlTextView.textStorage setAttributedString:attrString];
            }
                break;
            default:
                break;
        }
    } else {
        // 使用json内容生成
        NSMutableString *string = [self.generator generateWithJSON:self.jsonTextView.textStorage.string];
        [self.resultTextView insertText:string replacementRange:NSMakeRange(0, self.resultTextView.textStorage.string.length - 1)];
    }
}


- (ModelGenerator *)generator
{
    if (!_generator) {
        _generator = [[ModelGenerator alloc] init];
        _generator.window = self.view.window;
    }
    return _generator;
}

- (BMModelGenerator *)bmModelGenerator
{
    if (!_bmModelGenerator) {
        _bmModelGenerator = [[BMModelGenerator alloc] init];
    }
    return _bmModelGenerator;
}

- (BMNetCodeGenerator *)bmNetGenerator
{
    if (!_bmNetGenerator) {
        _bmNetGenerator = [[BMNetCodeGenerator alloc] init];
        _bmNetGenerator.jsonObjectName = self.generator.configModel.fileName;
    }
    return _bmNetGenerator;
}

- (PHModelGenerator *)phModelGenerator
{
    if (!_phModelGenerator) {
        _phModelGenerator = [[PHModelGenerator alloc] init];
    }
    return _phModelGenerator;
}

- (PHNetCodeGenerator *)phNetGenerator
{
    if (!_phNetGenerator) {
        _phNetGenerator = [[PHNetCodeGenerator alloc] init];
        _phNetGenerator.jsonObjectName = self.generator.configModel.fileName;
    }
    return _phNetGenerator;
}
@end
