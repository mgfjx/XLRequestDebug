//
//  XLRequestDetailController.m
//  XLRequestDebug
//
//  Created by mgfjx on 2023/11/21.
//

#import "XLRequestDetailController.h"

@interface XLRequestDetailController ()

@property (nonatomic, strong) UITextView *textView ;

@end

@implementation XLRequestDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextView *textView = [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO; // 禁用Autoresizing自动布局
    textView.font = [UIFont systemFontOfSize:16];
    textView.editable = NO;
    [self.view addSubview:textView];
//    textView.backgroundColor = [UIColor systemPinkColor];
    
    NSLayoutConstraint *leadingConstraint = [textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:2];
    NSLayoutConstraint *trailingConstraint = [textView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-2];
    NSLayoutConstraint *topConstraint = [textView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:2];
    NSLayoutConstraint *bottomConstraint = [textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-2];

    [self.view addConstraints:@[leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]];
    
    NSString *text = [NSString stringWithFormat:@"URL: \n%@\n\nMethod: \n%@\n\nHeaders: \n%@\n\nBody: \n%@\n\nStatusCode: \n%@\n\nResponse: \n%@\n", self.mode.url, self.mode.method, self.mode.header, self.mode.body, self.mode.statusCode, self.mode.respone];
    textView.text = text;
}



@end
