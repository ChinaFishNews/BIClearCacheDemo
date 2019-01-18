//
//  BISkinViewController.m
//  BIClearCacheDemo
//
//  Created by xinwen on 2019/1/18.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "BISkinViewController.h"

@interface BISkinViewController ()

@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;
@property (nonatomic, copy) NSString *filePath;

@end

@implementation BISkinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSString *homePath = NSHomeDirectory();
    NSString *libraryPath = @"/Library/RedSkin";
    self.filePath = [homePath stringByAppendingPathComponent:libraryPath];
}

+ (void)clearCache {
    NSLog(@"皮肤缓存清除完毕");
}

+ (NSNumber *)canClearSize {
    NSLog(@"皮肤缓存大小0.5M");
    return @(0.5);
}

- (void)updateFilePath {
    self.filePathLabel.text = @"被删除资源的路径：被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径被删除资源的路径";
    [self.filePathLabel sizeToFit];
}

#pragma mark - Actions
// 添加模块资源
- (IBAction)addResourcesAction:(id)sender {
    [self updateFilePath];
}

// 删除模块内所有缓存资源
- (IBAction)deleteAllResources:(id)sender {
    [self updateFilePath];
    [self.class clearCache];
}

// 删除指定路径下缓存资源
- (IBAction)deleteResourcesByFilePath:(id)sender {
    [self updateFilePath];
}

@end
