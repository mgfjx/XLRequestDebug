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
#import "XLDBManager.h"
//要过滤的url
NSArray *filterURLs(void) {
    return @[
        @"mobile-service/sdk/dc/ai",
    ];
}

BOOL isImageRequest(NSURL *url) {
    NSArray *arr = @[@"png", @"jpg", @"jpeg", @"icns", @"webp"];
    return [arr containsObject:url.pathExtension.lowercaseString];
}

//是否过滤请求
BOOL isFilterRequests(NSURL *url) {
    
    NSString *urlString = url.absoluteString;
    BOOL ignore = NO; //是否忽略 不打印
    for (NSString *shortUrl in filterURLs()) {
        if ([urlString containsString:shortUrl]) {
            ignore = YES;
            break;
        }
    }
    
    return ignore || isImageRequest(url);
}

id (*typed_msgSend)(id self, SEL _cmd, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) = (void *)objc_msgSend;
id (*typed2_msgSend)(id self, SEL _cmd, NSURLSession *session, NSURLSessionTask *task, NSError *error) = (void *)objc_msgSend;

@implementation NSURLSessionTask (Debug)

// 属性
static char *kDataKey = "kDataKey";
static char *kRequestIdKey = "kRequestIdKey";
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

- (void)setXl_requestId:(NSString *)xl_requestId {
    objc_setAssociatedObject(self, kRequestIdKey, xl_requestId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)xl_requestId {
    NSString *requestId = objc_getAssociatedObject(self, kRequestIdKey);
    return requestId;
}

+ (void)load {
    if ([XLRequestManager shared].enable) {
        Method system_method = class_getInstanceMethod([self class], @selector(resume));
        Method my_method = class_getInstanceMethod([self class], @selector(xl_resume));
        method_exchangeImplementations(system_method, my_method);
    }
}

- (void)xl_resume {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    self.xl_requestId = [NSString stringWithFormat:@"%ld", ((long)time*1000 + arc4random()%1000)];
    NSString *requestId = self.xl_requestId;
    NSURLRequest *request = self.currentRequest;
    if (!isFilterRequests(request.URL)) {
        [[XLDBManager manager] saveRequest:self];
        id params = nil;
        if (request.HTTPBody) {
            params = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:NSJSONReadingAllowFragments error:nil];
            if (!params) {
                NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
                params = [body componentsSeparatedByString:@"&"];
            }
        }
        NSString *message = [NSString stringWithFormat:
@"\n########################### 请求参数begin #################################\n\
url: %@\n\
method: %@\n\
requestId: %@\n\
header: %@\n\
body: %@\n\
########################### 请求参数end   #################################\
    ", request.URL.absoluteString, request.HTTPMethod, self.xl_requestId, request.allHTTPHeaderFields, params];
        NSLog(@"%@", message);
    }
    [self xl_resume];
}

@end


@implementation NSURLSession (Debug)

+ (void)load {
    if ([XLRequestManager shared].enable) {
        Method system_method = class_getClassMethod([self class], @selector(sessionWithConfiguration:delegate:delegateQueue:));
        Method my_method = class_getClassMethod([self class], @selector(xl_sessionWithConfiguration:delegate:delegateQueue:));
        method_exchangeImplementations(system_method, my_method);
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector" //忽略Undeclared Selector 警告
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
    if (!isFilterRequests(task.currentRequest.URL)) {
        [[XLDBManager manager] saveResponse:task error:error];
        if (error) {
            NSString *message = [NSString stringWithFormat:
@"\n========================== 服务返回begin ==========================\n\
url: %@\n\
error: %@\n\
========================== 服务返回end   ==========================\
        ", task.currentRequest.URL.absoluteString, error];
            NSLog(@"%@", message);
        } else {
            //拦截请求回调方法：在此处打印返回数据即可
            NSMutableData *data = [task.xl_data copy];
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableString *convertedString = [result mutableCopy];
            if (convertedString.length > 0) {
                [convertedString replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, convertedString.length)];
                CFStringRef transform = CFSTR("Any-Hex/Java");
                CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
            }
            result = convertedString;
            NSInteger statusCode = -1;
            if (task.response && [task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
            }
            NSString *requestId = task.xl_requestId;
            NSString *message = [NSString stringWithFormat:
@"\n========================== 服务返回begin ==========================\n\
url: %@,\n\
statusCode: %ld,\n\
requestId: %@,\n\
result:\n\
%@\n\
========================== 服务返回end   ==========================\
        ", task.currentRequest.URL.absoluteString, statusCode, requestId, result];
            NSLog(@"%@", message); //可能出现文本太长打印不全的情况，实际是完整的数据，可以打开下面的注释进行校验
            /*
            NSString *filePath = [NSString stringWithFormat:@"%@/note.txt", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            [message writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
             */
        }
    }
    typed2_msgSend(self, @selector(xl_URLSession:task:didCompleteWithError:), session, task, error);
}
#pragma clang diagnostic pop

@end
