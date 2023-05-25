//
//  XLRequestManager.m
//  XLRequestDebug
//
//  Created by mgfjx on 2023/5/24.
//

#import "XLRequestManager.h"

#define kXLRequestManagerEnable @"kXLRequestManagerEnable"

@implementation XLRequestManager

static id singleton = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleton = [super allocWithZone:zone];
        });
    }
    return singleton;
}

- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [super init];
    });
    return singleton;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return singleton;
}

+ (instancetype)shared{
    return [[self alloc] init];
}

- (void)setEnable:(BOOL)enable {
    NSLog(@"%@", NSThread.currentThread);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enable forKey:kXLRequestManagerEnable];
    [defaults synchronize];
}

- (BOOL)enable {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kXLRequestManagerEnable];
}

@end
