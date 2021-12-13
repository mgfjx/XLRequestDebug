//
//  NSURLSessionTask+Debug.m
//  TaiTelevision
//
//  Created by mgfjx on 2021/12/11.
//  Copyright © 2021 mgfjx. All rights reserved.
//

#import "NSURLSessionTask+Debug.h"
#import <objc/runtime.h>
#import <objc/message.h>

id (*typed_msgSend)(id self, SEL _cmd, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) = (void *)objc_msgSend;

@implementation NSURLSessionTask (Debug)

+ (void)load {
    Method system_method = class_getInstanceMethod([self class], @selector(resume));
    Method my_method = class_getInstanceMethod([self class], @selector(xl_resume));
    method_exchangeImplementations(system_method, my_method);
    
    {
        Method system_method = class_getInstanceMethod([self class], @selector(setDelegate:));
        Method my_method = class_getInstanceMethod([self class], @selector(xl_setDelegate:));
        method_exchangeImplementations(system_method, my_method);
    }
}

- (void)xl_setDelegate:(id)obj {
    [self xl_setDelegate:obj];
}

- (void)xl_resume {
    NSURLRequest *request = self.currentRequest;
    NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    NSArray *params = [body componentsSeparatedByString:@"&"];
    NSString *message = [NSString stringWithFormat:
@"\n########################### 请求参数begin #################################\n\
url: %@\n\
method: %@\n\
header: %@\n\
body: %@\n\
########################### 请求参数end   #################################\
", request.URL.absoluteString, request.HTTPMethod, request.allHTTPHeaderFields, params];
    NSLog(@"%@", message);
    [self xl_resume];
}

@end


@implementation NSURLSession (Debug)

+ (void)load {
    Method system_method = class_getClassMethod([self class], @selector(sessionWithConfiguration:delegate:delegateQueue:));
    Method my_method = class_getClassMethod([self class], @selector(xl_sessionWithConfiguration:delegate:delegateQueue:));
    method_exchangeImplementations(system_method, my_method);
}

+ (NSURLSession *)xl_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue {
    BOOL success = class_addMethod(delegate.class, @selector(xl_URLSession:dataTask:didReceiveData:), (IMP)xl_URLSession, "V@:");
    if (success) {
        if ([delegate respondsToSelector:@selector(xl_URLSession:dataTask:didReceiveData:)]) {
//            typed_msgSend(delegate, @selector(xl_URLSession:task:didCompleteWithError:), @"", @"", @"");
            Method system_method = class_getInstanceMethod([delegate class], @selector(URLSession:dataTask:didReceiveData:));
            Method my_method = class_getInstanceMethod([delegate class], @selector(xl_URLSession:dataTask:didReceiveData:));
            method_exchangeImplementations(system_method, my_method);
        }
    }
    return [self xl_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

void xl_URLSession(id self, SEL _cmd, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
    //拦截请求回调方法：在此处打印返回数据即可
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *message = [NSString stringWithFormat:
@"\n========================== 服务返回begin ==========================\n\
url: %@,\n\
result: %@\n\
========================== 服务返回end   ==========================\
", dataTask.currentRequest.URL.absoluteString, result];
    NSLog(@"%@", message);
    typed_msgSend(self, @selector(xl_URLSession:dataTask:didReceiveData:), session, dataTask, data);
}

@end
