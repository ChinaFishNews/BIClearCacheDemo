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
@property (nonatomic, strong) NSArray <NSString *> *cacheDirPath;
@property (nonatomic, strong) NSArray <NSString *> *cacheFilePath;
@end

@implementation BIClearCacheModel

@end

@interface BIClearCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *moduleNameAndSizeDic; // 模块名：缓存大小
@property (nonatomic, assign) SEL clearCacheSel; // 清除缓存方法

@property (nonatomic, strong) NSArray <BIClearCacheModel *> *moduleArray;

@end

@implementation BIClearCacheManager

+ (instancetype)sharedManager {
    static BIClearCacheManager *instanceType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceType = [[BIClearCacheManager alloc]init];
        [instanceType initPlistFile];
        [instanceType readFromPlist];
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

#pragma mark - 手动指定可删除缓存资源
- (void)setCacheFile:(NSString *)filePath module:(BIModuleName)module
{
    
}

- (void)setCacheDir:(NSString *)fileDir module:(BIModuleName)module
{
    
}

//单位：MB
- (NSNumber *)cacheSizeOfModule:(BIModuleName)module
{
    BIClearCacheModel *model = _moduleArray[[self indexOfModule:module]];
    
    long long totalFileSize = [self totalFileSizeAtPathArray:model.cacheFilePath];
    
    long long totalDirSize = [self totalDirSizeAtPathArray:model.cacheDirPath];
    
    return @((totalFileSize + totalDirSize)/1024.0/1024.0);
}

- (void)clearCacheWithModule:(BIModuleName)module complete:(void (^)(void))completeBlock
{
    __weak BIClearCacheManager *weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BIClearCacheModel *model = self.moduleArray[[weakself indexOfModule:module]];
    
        //删文件和索引
        //Todo:删索引
        [weakself deleteFilesAtPathArray:model.cacheFilePath];
        //删目录和索引
        //Todo:删索引
        [weakself deleteFilesAtPathArray:model.cacheDirPath];
        
        //返回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock();
            }
        });
    });
    
}

#pragma mark - util method

- (void)deleteFilesAtPathArray:(NSArray<NSString *> *)array
{
    for (NSString *filePath in array)
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (void)deleteDirsAtPathArray:(NSArray<NSString *> *)array
{
    for (NSString *dirPath in array)
    {
        //Todo:是否考虑递归
        [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
    }
}

- (long long)totalFileSizeAtPathArray:(NSArray<NSString *> *)array
{
    long long result = 0;
    for (NSString *filePath in array)
    {
        long long fileSize = [self fileSizeAtPath:filePath];
        result += fileSize;
    }
    return result;
}

- (long long)totalDirSizeAtPathArray:(NSArray<NSString *> *)array
{
    long long result = 0;
    for (NSString *dirPath in array)
    {
        long long dirSize = [self folderSizeAtPath:dirPath];
        result += dirSize;
    }
    return result;
}

//单位：B
- (long long)fileSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size;
    }
    return 0;
}

//单位：B
- (long long)folderSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    cachePath = [cachePath stringByAppendingPathComponent:path];
    long long folderSize = 0;
    if ([fileManager fileExistsAtPath:cachePath])
    {
        NSArray *childerFiles = [fileManager subpathsAtPath:cachePath];
        for (NSString *fileName in childerFiles)
        {
            NSString *fileAbsolutePath = [cachePath stringByAppendingPathComponent:fileName];
            long long size = [self fileSizeAtPath:fileAbsolutePath];
            folderSize += size;
        }
        return folderSize;
    }
    return 0;
}

- (void)initPlistFile
{
    //本地没有则拷贝plist，文件到Doc目录
    
    //有的话，进行merge
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self plistPath]])
    {
        [[NSFileManager defaultManager] copyItemAtPath:[self bundlePlistFile] toPath:[self plistPath] error:nil];
    }
    else
    {
        //Todo
    }
}

- (void)readFromPlist
{
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:[self plistPath]];
    NSMutableArray *tempModuleArray = [[NSMutableArray alloc]init];
    for (NSDictionary *plistDicItem in plistArray)
    {
        BIClearCacheModel *model = [[BIClearCacheModel alloc]init];
        model.moduleDisplayName = plistDicItem[@"moduleName"];
        model.moduleName = [plistDicItem[@"moduleID"] integerValue];
        model.managerClassName = plistDicItem[@"className"];
        model.cacheDirPath = plistDicItem[@"cacheDirPath"];
        model.cacheFilePath = plistDicItem[@"cacheFilePath"];
        
        [tempModuleArray addObject:model];
    }
    _moduleArray = [NSArray arrayWithArray:tempModuleArray];
    
}

- (NSString *)bundlePlistFile
{
    return [[NSBundle mainBundle]pathForResource:@"AllModuleCacheConfig" ofType:@"plist"];
}

- (NSString *)plistPath
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [docPath stringByAppendingPathComponent:@"AllModuleCacheConfig.plist"];
}

- (NSUInteger)indexOfModule:(BIModuleName)module
{
    NSUInteger result = 0;
    
    for (int i = 0; i < _moduleArray.count; i++)
    {
        BIClearCacheModel *model = _moduleArray[i];
        if (model.moduleName == module) {
            result = i;
            break;
        }
    }
    return result;
}

@end
