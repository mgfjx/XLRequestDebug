//
//  XLTableViewController.m
//  XLRequestDebug_Example
//
//  Created by mgfjx on 2021/12/13.
//  Copyright © 2021 xxl. All rights reserved.
//

#import "XLTableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+MD5.h"
#import <XLRequestDebug/XLRequestManager.h>

@interface XLTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray ;
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XLTableViewController


- (IBAction)blockRequest:(UISwitch *)sender {
    [XLRequestManager shared].enable = sender.on;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.onSwitch.on = [XLRequestManager shared].enable;
    
    self.title = @"Request List";
    
    self.dataArray = @[
        @{@"title": @"POST", @"selector": NSStringFromSelector(@selector(postRequest))},
        @{@"title": @"GET", @"selector": NSStringFromSelector(@selector(getRequest))},
    ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    
//    [self createTableView];
}

- (void)createTableView {
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    self.tableView = table;
    
    
    
}

- (void)postRequest {
    NSLog(@"postRequest");
    NSString *appid = @"20220505001203855";
    NSString *query = @"你是傻逼";
    NSString *salt = @"1231231";
    NSString *signBefore = [NSString stringWithFormat:@"%@%@%@kgLnrss5MVpucE8LOON1", appid, query, salt];
    NSString *sign = [[NSString getmd5Str:signBefore] lowercaseString];
    NSDictionary *param = @{
        @"q": query,
        @"from": @"zh",
        @"to": @"en",
        @"appid": appid,
        @"salt": salt,
        @"sign": sign
    };
    NSLog(@"-------");
    [[AFHTTPSessionManager manager] POST:@"https://fanyi-api.baidu.com/api/trans/vip/translate" parameters:param headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@", error);
    }];
}

- (void)getRequest {
    NSLog(@"getRequest");
    [[AFHTTPSessionManager manager] GET:@"https://v0.yiketianqi.com/api" parameters:@{
        @"unescape": @(1),
        @"version": @"v61",
        @"appid": @"29578935",
        @"appsecret": @"0NBY2H0r",
        @"cityid": @"101200113",
    } headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    
    cell.textLabel.text = [self.dataArray[indexPath.row] objectForKey:@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *info = self.dataArray[indexPath.row];
    NSString *selector = [info objectForKey:@"selector"];
    [self performSelector:NSSelectorFromString(selector)];
}

@end
