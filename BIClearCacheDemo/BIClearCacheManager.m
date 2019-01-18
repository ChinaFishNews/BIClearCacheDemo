//
//  BIClearCacheManager.m
//  BaiduInputMethodContainer
//
//  Created by xinwen on 2019/1/14.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "BIClearCacheManager.h"

@interface BIClearCacheModel : NSObject

@property (nonatomic, strong) NSString *moduleDisplayName;
@property (nonatomic, assign) BIModuleName moduleName;
@property (nonatomic, strong) NSString *managerClassName;
@property (nonatomic, strong) NSArray <NSString *> *cachePath;

@end

@implementation BIClearCacheModel

@end

@interface BIClearCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *moduleNameAndSizeDic; // 模块名：缓存大小
@property (nonatomic, assign) SEL clearCacheSel; // 清除缓存方法

@end

@implementation BIClearCacheManager

+ (instancetype)sharedManager {
    static BIClearCacheManager *instanceType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceType = [[BIClearCacheManager alloc]init];
        [instanceType mergePlist];
    });
    return instanceType;
}

#pragma mark - 删除模块内所有可清除缓存资源
// 获取所有子模块模块名和可清除缓存大小
- (NSDictionary <NSString *,NSNumber *> *)allModuleNameAndSize {
    self.moduleNameAndSizeDic = @{}.mutableCopy;
    self.moduleNameArray = @[].mutableCopy;
    self.moduleSizeArray = @[].mutableCopy;
    self.classNameArray = @[].mutableCopy;
    
    NSString *plsiPath = [[NSBundle bundleForClass:self.class] pathForResource:@"AllModuleCacheConfig" ofType:@"plist"];
    NSArray* moduleArr = [NSArray arrayWithContentsOfFile:plsiPath];
    for (NSDictionary *moduleDic in moduleArr) {
        /*
         key
         moduleName:模块名
         className：类名
         clearCacheActionName:清理缓存方法名
         returnSizeActionName：返回缓存大小方法名
         */
       
        // 类名
        NSString *className = moduleDic[@"className"];
        [self.classNameArray addObject:className];
        // 返回缓存大小方法名
        NSString *returnSizeActionName = moduleDic[@"returnSizeActionName"];
        Class targetClass = NSClassFromString(className);
        SEL targetAction = NSSelectorFromString(returnSizeActionName);
        if ([targetClass respondsToSelector:targetAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
           NSNumber * size = [targetClass performSelector:targetAction withObject:nil];
#pragma clang diagnostic pop
            if (size.floatValue > 0) {
                [self.moduleSizeArray addObject:size];
                // 模块名
                [self.moduleNameArray addObject:moduleDic[@"moduleName"]];
                // 模块名：模块缓存大小
                self.moduleNameAndSizeDic[moduleDic[@"moduleName"]] = size;
                
                // 清除缓存方法
                NSString *clearCacheActionName = moduleDic[@"clearCacheActionName"];
                self.clearCacheSel = NSSelectorFromString(clearCacheActionName);
            }
        }
    }

    return self.moduleNameAndSizeDic;
}

// 清除所有模块缓存
- (void)allModuleClearCahce:(void (^)(void))complete {
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString *className in self.classNameArray) {
        Class targetClass = NSClassFromString(className);
        if ([targetClass respondsToSelector:self.clearCacheSel]) {
            
            dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [targetClass performSelector:self.clearCacheSel withObject:nil];
#pragma clang diagnostic pop
            });
        }
    }
    // 所有任务都完成后发送这个通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"清除任务全部完成");
        complete();
    });
}

// 删除某个模块的缓存
- (void)clearCacheWithModuleName:(NSString *)moduleName complete:(void (^)(void))complete {
    dispatch_group_t group = dispatch_group_create();
    
    NSInteger index = [self.moduleNameArray indexOfObject:moduleName];
    Class targetClass = NSClassFromString(self.classNameArray[index]);
     if ([targetClass respondsToSelector:self.clearCacheSel]) {
         dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             [targetClass performSelector:self.clearCacheSel withObject:nil];
#pragma clang diagnostic pop
         });
     }
    // 模块缓存删除完毕
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"模块缓存删除完毕");
        complete();
    });
}

#pragma mark - 根据目录删除部分缓存资源
- (void)setCacheFile:(NSString *)filePath module:(BIModuleName)module
{
    
}

- (void)setCacheDir:(NSString *)fileDir module:(BIModuleName)module
{
    
}

- (NSNumber *)cacheSizeOfModule:(BIModuleName)module
{
    return @0;
}

#pragma mark - util method
- (void)mergePlist
{
    
}

@end
