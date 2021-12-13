//
//  XLTableViewController.m
//  XLRequestDebug_Example
//
//  Created by mgfjx on 2021/12/13.
//  Copyright © 2021 xxl. All rights reserved.
//

#import "XLTableViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface XLTableViewController ()

@property (nonatomic, strong) NSArray *dataArray ;

@end

@implementation XLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Request List";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];;
    
    self.dataArray = @[
        @{@"title": @"POST", @"selector": NSStringFromSelector(@selector(postRequest))},
        @{@"title": @"GET", @"selector": NSStringFromSelector(@selector(getRequest))},
    ];
}

- (void)postRequest {
    NSLog(@"postRequest");
}

- (void)getRequest {
    NSLog(@"getRequest");
    [[AFHTTPSessionManager manager] GET:@"https://gutendex.com/books/" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
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
