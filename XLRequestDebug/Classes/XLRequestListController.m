//
//  XLRequestListController.m
//  XLRequestDebug
//
//  Created by mgfjx on 2023/5/25.
//

#import "XLRequestListController.h"
#import "XLDBManager.h"
#import "XLRequestListCell.h"
#import "XLRequestDetailController.h"

@interface XLRequestListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray ;

@end

@implementation XLRequestListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Request List";
    self.view.backgroundColor = [[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    
    self.dataArray = [[XLDBManager manager] queryAllRequests:0];
    
    [self createTableView];
}

- (void)createTableView {
    CGRect frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    UITableView *table = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = [UIColor colorWithRed:0.9176470588235294 green:0.9176470588235294 blue:0.9176470588235294 alpha:1.0F];
    [self.view addSubview:table];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellReuse = @"kRequestListCellKey";
    XLRequestListCell *cell = (XLRequestListCell *)[tableView dequeueReusableCellWithIdentifier:cellReuse];
    
    if (!cell) {
        cell = [[XLRequestListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellReuse];
    }
    
    cell.mode = self.dataArray[indexPath.row];
    if (indexPath.row % 2 != 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.9176470588235294 green:0.9176470588235294 blue:0.9176470588235294 alpha:1.0F];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XLRequestDetailController *vc = [[XLRequestDetailController alloc] init];
    vc.mode = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
