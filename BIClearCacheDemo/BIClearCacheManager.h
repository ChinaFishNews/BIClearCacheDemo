//
//  BIClearCacheManager.h
//  BaiduInputMethodContainer
//
//  Created by xinwen on 2019/1/14.
//  Copyright © 2019年 baidu. All rights reserved.
//  清除缓存管理类

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    BIModuleNameSDWebImage = 0,
    BIModuleNameSkin = 1,
} BIModuleName;

@interface BIClearCacheManager : NSObject

@property (nonatomic, strong) NSMutableArray *moduleNameArray; // 模块名
@property (nonatomic, strong) NSMutableArray *moduleSizeArray; // 模块可清除缓存大小
@property (nonatomic, strong) NSMutableArray *classNameArray; // 模块下的类名

+ (instancetype)sharedManager;

#pragma mark - 删除模块内所有可清除缓存资源
// 获取所有子模块模块名和可清除缓存大小
- (NSDictionary <NSString *,NSNumber *> *)allModuleNameAndSize;

// 清除所有模块缓存
- (void)allModuleClearCahce:(void (^)(void))complete;

// 删除某个模块的缓存
- (void)clearCacheWithModuleName:(NSString *)moduleName complete:(void (^)(void))complete;

#pragma mark - 手动指定可删除缓存资源
- (void)setCacheFile:(NSString *)filePath module:(BIModuleName)module;

- (void)setCacheDir:(NSString *)fileDir module:(BIModuleName)module;

- (NSNumber *)cacheSizeOfModule:(BIModuleName)module;

- (void)clearCacheWithModule:(BIModuleName)module complete:(void (^)(void))complete;

@end

