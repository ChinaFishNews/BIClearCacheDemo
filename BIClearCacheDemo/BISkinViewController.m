//
//  BISkinViewController.m
//  BIClearCacheDemo
//
//  Created by xinwen on 2019/1/18.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "BISkinViewController.h"
#import "BIClearCacheManager.h"

#define SKIN_PATH [NSHomeDirectory() stringByAppendingString:@"/Library/Skin/"]

@interface BISkinViewController () 

@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;

@end

@implementation BISkinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (void)clearCache {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:SKIN_PATH error:&error];
    if (!error) {
        NSLog(@"delete success");
    } else {
        NSLog(@"delete faile");
    }
}

+ (NSNumber *)canClearSize {
    NSLog(@"可清理缓存大小");
    float size = [BISkinViewController folderSizeAtPath:SKIN_PATH];
    return [NSNumber numberWithFloat:[[NSString stringWithFormat:@"%0.2f",size] floatValue]];;
}

#pragma mark - Actions
// 添加模块资源
- (IBAction)addResourcesAction:(id)sender {
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"lkw" ofType:@"bin"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:SKIN_PATH isDirectory:&isDir];
    // 创建文件夹
    if (!(isDir && existed)) {
         [fileManager createDirectoryAtPath:SKIN_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *destionPath = [SKIN_PATH stringByAppendingPathComponent:[bundlePath lastPathComponent]];
    NSError *error = nil;
    // 复制文件到指定目录
    if (![fileManager fileExistsAtPath:destionPath]) {
        [fileManager copyItemAtPath:bundlePath toPath:destionPath error:&error];
    }

    if (!error) {
        NSLog(@"copy success");
        [self updateFilePath:[NSString stringWithFormat:@"已添加资源文件到%@",SKIN_PATH]];
    } else {
        NSLog(@"copy fail");
    }
}

// 删除模块内所有缓存资源
- (IBAction)deleteAllResources:(id)sender {
    [self.class clearCache];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:SKIN_PATH error:&error];
    if (!error) {
        NSLog(@"delete success");
        [self updateFilePath:@"遍历删除沙盒所有目录下的缓存"];
    } else {
        NSLog(@"delete faile");
    }
}

// 删除指定路径下缓存资源
- (IBAction)deleteResourcesByFilePath:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    __block NSError *error = nil;
    // 该目录下所有目录
    NSArray *array = [fileManager contentsOfDirectoryAtPath:SKIN_PATH error:nil];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 删除该目录下所有资源
        [fileManager removeItemAtPath:SKIN_PATH error:&error];
    }];
    if (!error) {
        NSLog(@"delete success");
        [self updateFilePath:[NSString stringWithFormat:@"删除%@目录下缓存",SKIN_PATH]];
    } else {
        NSLog(@"delete faile");
    }
}

#pragma mark - Private
// 获取文件夹大小
+ (float)folderSizeAtPath:(NSString *)folderPath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [BISkinViewController fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

// 获取单个文件大小
+ (long long)fileSizeAtPath:(NSString*)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)updateFilePath:(NSString *)notice {
    self.filePathLabel.text = [NSString stringWithFormat:@"%@",notice];
    [self.filePathLabel sizeToFit];
}

@end
