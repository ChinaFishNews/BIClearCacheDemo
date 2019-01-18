//
//  BIImageViewController.m
//  BIClearCacheDemo
//
//  Created by xinwen on 2019/1/18.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "BIImageViewController.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@interface BIImageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *imageList;

@end

@implementation BIImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageList = @[@"http://img.daimg.com/uploads/allimg/190116/3-1Z116231001.jpg",
                       @"http://img.daimg.com/uploads/allimg/190116/3-1Z116225U6.jpg",
                       @"http://img.daimg.com/uploads/allimg/190116/3-1Z116000201.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z115235430.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z115234921.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z115223620.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z115221H3.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z115215537.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z1151GQ9.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z1151G424.jpg",
                       @"http://img.daimg.com/uploads/allimg/190115/3-1Z115162236.jpg"];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        imageView.tag = indexPath.row + 100;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [cell.contentView addSubview:imageView];
    }
    UIImageView *bgImageView = [cell.contentView viewWithTag:indexPath.row +100];
    NSString *imageUrlString =self.imageList[indexPath.row];
    [bgImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlString]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 清理缓存
// 清理当前模块缓存
+ (void)clearCache {
    // 清理内存缓存
    [[SDImageCache sharedImageCache] clearMemory];
    // 清除磁盘缓存
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    NSLog(@"图片清除完毕");
}

// 获取当前模块可清缓存的大小
+ (NSNumber *)canClearSize {
    NSInteger tmpSize = [[SDImageCache sharedImageCache] getSize];
    float tempResult = tmpSize /(1024.f*1024.f);
    NSLog(@"清理图片缓存%0.2f",tempResult);;
    return [NSNumber numberWithFloat:[[NSString stringWithFormat:@"%0.2f",tempResult] floatValue]];
}

@end
