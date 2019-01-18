//
//  BISkinViewController.m
//  BIClearCacheDemo
//
//  Created by xinwen on 2019/1/18.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "BISkinViewController.h"

@interface BISkinViewController ()

@end

@implementation BISkinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

+ (void)clearCache {
    NSLog(@"BISkinClass 清除完毕");
}

+ (NSNumber *)canClearSize {
    NSLog(@"BISkinClass 缓存大小0.5M");
    return @(0.5);
}

@end
