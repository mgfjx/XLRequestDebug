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
id (*typed2_msgSend)(id self, SEL _cmd, NSURLSession *session, NSURLSessionTask *task, NSError *error) = (void *)objc_msgSend;

@implementation NSURLSessionTask (Debug)

// 属性
static char *kDataKey = "xl_data";
- (void)setXl_data:(NSMutableData *)xl_data {
    objc_setAssociatedObject(self, kDataKey, xl_data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableData *)xl_data {
    NSMutableData *data = objc_getAssociatedObject(self, kDataKey);
    if (!data) {
        data = [NSMutableData data];
        self.xl_data = data;
    }
    return data;
}

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
    //hook方法：URLSession:dataTask:didReceiveData:
    {
        BOOL success = class_addMethod(delegate.class, @selector(xl_URLSession:dataTask:didReceiveData:), (IMP)xl_URLSessionReceiveData, "V@:");
        if (success) {
            if ([delegate respondsToSelector:@selector(xl_URLSession:dataTask:didReceiveData:)]) {
    //            typed_msgSend(delegate, @selector(xl_URLSession:task:didCompleteWithError:), @"", @"", @"");
                Method system_method = class_getInstanceMethod([delegate class], @selector(URLSession:dataTask:didReceiveData:));
                Method my_method = class_getInstanceMethod([delegate class], @selector(xl_URLSession:dataTask:didReceiveData:));
                method_exchangeImplementations(system_method, my_method);
            }
        }
    }
    //hook方法：URLSession:dataTask:didReceiveData:
    {
        BOOL success = class_addMethod(delegate.class, @selector(xl_URLSession:task:didCompleteWithError:), (IMP)xl_URLSessionDidComplete, "V@:");
        if (success) {
            if ([delegate respondsToSelector:@selector(xl_URLSession:task:didCompleteWithError:)]) {
                Method system_method = class_getInstanceMethod([delegate class], @selector(URLSession:task:didCompleteWithError:));
                Method my_method = class_getInstanceMethod([delegate class], @selector(xl_URLSession:task:didCompleteWithError:));
                method_exchangeImplementations(system_method, my_method);
            }
        }
    }
    return [self xl_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

//xl_URLSession:dataTask:didReceiveData: 实现
void xl_URLSessionReceiveData(id self, SEL _cmd, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
    //拦截请求回调方法：在此处打印返回数据即可
    [dataTask.xl_data appendData:data];
    typed_msgSend(self, @selector(xl_URLSession:dataTask:didReceiveData:), session, dataTask, data);
}

//xl_URLSession:task:didCompleteWithError: 实现
void xl_URLSessionDidComplete(id self, SEL _cmd, NSURLSession *session, NSURLSessionTask *task, NSError *error) {
    //拦截请求回调方法：在此处打印返回数据即可
    NSMutableData *data = [task.xl_data copy];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *message = [NSString stringWithFormat:
@"\n========================== 服务返回begin ==========================\n\
url: %@,\n\
result: %@\n\
========================== 服务返回end   ==========================\
", task.currentRequest.URL.absoluteString, result];
    NSLog(@"%@", message); //可能出现文本太长打印不全的情况，实际是完整的数据，可以打开下面的注释进行校验
    /*
    NSString *filePath = [NSString stringWithFormat:@"%@/note.txt", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    [message writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
     */
    typed2_msgSend(self, @selector(xl_URLSession:task:didCompleteWithError:), session, task, error);
}

@end
