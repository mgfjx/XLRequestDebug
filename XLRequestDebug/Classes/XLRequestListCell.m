//
//  XLRequestListCell.m
//  XLRequestDebug
//
//  Created by mgfjx on 2023/11/21.
//

#import "XLRequestListCell.h"
#import "UIColor+Hex.h"

@interface XLRequestListCell ()

@property (nonatomic, strong) UIImageView *iconView ;
@property (nonatomic, strong) UIImageView *hdImgView ;
@property (nonatomic, strong) UILabel *methodLabel ;
@property (nonatomic, strong) UILabel *urlLabel ;
@property (nonatomic, strong) UILabel *statusLabel ;

@end

@implementation XLRequestListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    
    UILabel *urlLabel = [UILabel new];
    urlLabel.textColor = [UIColor blackColor];
    urlLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:urlLabel];
    self.urlLabel = urlLabel;
    urlLabel.frame = CGRectMake(5, 5, 400, 20);
    
    UILabel *methodLabel = [UILabel new];
    methodLabel.textColor = [UIColor blackColor];
    methodLabel.font = [UIFont systemFontOfSize:10];
    methodLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:methodLabel];
    self.methodLabel = methodLabel;
    methodLabel.frame = CGRectMake(CGRectGetMinX(urlLabel.frame), CGRectGetMaxY(urlLabel.frame) + 5, 35, 15);
    
    UILabel *statusLabel = [UILabel new];
    statusLabel.textColor = [UIColor blackColor];
    statusLabel.font = [UIFont systemFontOfSize:8];
    [self.contentView addSubview:statusLabel];
    self.statusLabel = statusLabel;
    statusLabel.frame = CGRectMake(CGRectGetMaxX(methodLabel.frame), 0, 30, 20);
    statusLabel.center = CGPointMake(statusLabel.center.x, CGRectGetMidY(methodLabel.frame));
    
//    self.methodLabel.backgroundColor = [UIColor randomColorWithAlpha:0.3];
//    self.urlLabel.backgroundColor = [UIColor randomColorWithAlpha:0.3];
//    self.statusLabel.backgroundColor = [UIColor randomColorWithAlpha:0.3];
 
}

- (void)setMode:(XLRequestMode *)mode {
    _mode = mode;
    
    self.methodLabel.text = mode.method;
    self.urlLabel.text = mode.url;
    self.statusLabel.text = mode.statusCode;
}

@end
