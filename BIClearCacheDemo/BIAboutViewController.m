//
//  BIAboutViewController.m
//  BIClearCacheDemo
//
//  Created by xinwen on 2019/1/18.
//  Copyright © 2019年 baidu. All rights reserved.
//

#import "BIAboutViewController.h"
#import "BIClearCacheManager.h"

@interface BIAboutViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *clearCacheButton;
@property (nonatomic, strong) NSDictionary *moduleNameAndSizeDic;
@property (nonatomic, strong) NSMutableArray *moduleNameArray; // 模块名
@property (nonatomic, strong) NSMutableArray *moduleSizeArray; // 模块可清除缓存大小
@property (nonatomic, strong) NSMutableArray *classNameArray; // 模块下的类名

@end

@implementation BIAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title = @"清理缓存";
    [self configTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self congfigDataSource];
}

- (void)configTableView {
    self.clearCacheButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearCacheButton setTitle:@"清除所有缓存" forState:UIControlStateNormal];
    [self.clearCacheButton addTarget:self action:@selector(clearAllCacheAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.clearCacheButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

- (void)congfigDataSource {
    self.moduleNameAndSizeDic = [BIClearCacheManager sharedManager].allModuleNameAndSize;
    self.moduleNameArray = [BIClearCacheManager sharedManager].moduleNameArray;
    self.moduleSizeArray = [BIClearCacheManager sharedManager].moduleSizeArray;
    self.classNameArray = [BIClearCacheManager sharedManager].classNameArray;
    
    [self.tableView reloadData];
}

#pragma mark - Action
// 清除所有模块缓存
- (void)clearAllCacheAction {
    self.clearCacheButton.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [[BIClearCacheManager sharedManager] allModuleClearCahce:^{
        weakSelf.clearCacheButton.enabled = YES;
        [weakSelf congfigDataSource]; // 更新数据源
        NSLog(@"清理成功");
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.moduleNameAndSizeDic.allKeys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    NSString *moduleName = self.moduleNameArray[indexPath.row];
    cell.textLabel.text = moduleName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"可清除缓存%@M",self.moduleNameAndSizeDic[moduleName]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    NSString *moduleName = self.moduleNameArray[indexPath.row];
    //  删除指定模块缓存
    [[BIClearCacheManager sharedManager] clearCacheWithModuleName:moduleName complete:^{
        [weakSelf congfigDataSource];  // 更新数据源
        NSLog(@"%@",[NSString stringWithFormat:@"%@缓存清理完成",moduleName]);
    }];
}

@end
