//
//  NSURLSessionTask+XLDealloc.m
//  XLRequestDebug_Example
//
//  Created by mgfjx on 2021/12/14.
//  Copyright © 2021 xxl. All rights reserved.
//

#import "NSURLSessionTask+XLDealloc.h"
#import "NSURLSessionTask+Debug.h"

@implementation NSURLSessionTask (XLDealloc)

- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass(self.class));
}

@end
