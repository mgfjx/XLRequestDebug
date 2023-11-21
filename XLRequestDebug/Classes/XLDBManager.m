//
//  XLDBManager.m
//  XLRequestDebug
//
//  Created by mgfjx on 2023/11/20.
//

#import "XLDBManager.h"
#import <fmdb/FMDB.h>
#import "NSURLSessionTask+Debug.h"
#import "XLRequestMode.h"

static XLDBManager *singleton ;

#define LimitSize 50;

@interface XLDBManager ()

@property (nonatomic, strong) FMDatabase *db ;

@end

@implementation XLDBManager

#pragma mark 字典转化字符串
- (NSString *)objectToJson:(id)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *temp = [json stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *result = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return result;
}

- (id)objectWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return obj;
}

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[XLDBManager alloc] init];
        [singleton initDataBase];
    });
    return singleton ;
}

- (void)initDataBase {
    
    NSString *dbPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    dbPath = [NSString stringWithFormat:@"%@/XLRequest.db", dbPath];
    self.dbPath = dbPath ;
    NSLog(@"dbPath: %@", dbPath);
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    self.db = db;
    [db open];
    if (![db open]) {
        NSLog(@"db open fail");
        return;
    }
    
    {
        NSString *sql = @"create table if not exists RequestTable (\
                        'ID' INTEGER PRIMARY KEY AUTOINCREMENT,\
                        'requestId' TEXT NOT NULL,\
                        'url' TEXT NOT NULL,\
                        'method' TEXT NOT NULL,\
                        'header' TEXT NOT NULL,\
                        'body' TEXT,\
                        'statusCode' TEXT,\
                        'respone' TEXT\
                        )";
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"create table success");
        }
    }
    
    //影片详情增加磁力链接
    {
//        if (![db columnExists:@"magnetic" inTableWithName:@"MovieDetailTable"]) {
//            NSString *alertStr = @"ALTER TABLE MovieDetailTable ADD magnetic TEXT" ;
//            [db executeUpdate:alertStr];
//        }
    }
    
    [db close];
    
}

- (BOOL)baseUpdateSql:(NSString *)sql {
    [self.db open];
    BOOL result = [self.db executeUpdate:sql];
    [self.db close];
    return result;
}

///save request
- (BOOL)saveRequest:(NSURLSessionTask *)task {
    NSURLRequest *request = task.currentRequest;
    NSString *urlString = request.URL.absoluteString;
    NSString *method = request.HTTPMethod;
    NSString *headers = [self dictToString:request.allHTTPHeaderFields];
    id params = nil;
    if (request.HTTPBody) {
        params = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:NSJSONReadingAllowFragments error:nil];
        if (!params) {
            NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
            body = [body stringByRemovingPercentEncoding];
            NSArray *arr = [body componentsSeparatedByString:@"&"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (NSString *item in arr) {
                NSArray *keyvalues = [item componentsSeparatedByString:@"="];
                if (keyvalues.count == 2) {
                    NSString *key = keyvalues.firstObject;
                    NSString *value = keyvalues.lastObject;
                    dict[key] = value;
                }
            }
            
            params = [self dictToString:dict];
        }
    }
    NSString *sql = [NSString stringWithFormat:@"insert into 'RequestTable'(requestId,url,method,header,body) values('%@','%@','%@','%@','%@')", task.xl_requestId, urlString, method, headers, params];
    BOOL success = [self baseUpdateSql:sql];
    return success;
}

///save response
- (BOOL)saveResponse:(NSURLSessionTask *)task error:(NSError *)error {
    BOOL isExist = [self isRequestExsit:task];
    NSURLRequest *request = task.currentRequest;
    NSString *urlString = request.URL.absoluteString;
    NSString *method = request.HTTPMethod;
    NSString *headers = [self dictToString:request.allHTTPHeaderFields];
    
    NSString *sql;
    if (error) {
        NSString *errorInfo = [NSString stringWithFormat:@"%@", error];
        NSString *statusCodeStr = @"-1";
        if (isExist) {
            sql = [NSString stringWithFormat:@"update 'RequestTable' set url='%@',method='%@',header='%@',statusCode='%@',respone='%@' where requestId='%@'", urlString, method, headers, statusCodeStr, errorInfo, task.xl_requestId];
        } else {
            sql = [NSString stringWithFormat:@"insert into 'RequestTable'(requestId, url,method,header,statusCode,respone) values('%@','%@','%@','%@','%@','%@')", task.xl_requestId, urlString, method, headers, statusCodeStr, errorInfo];
        }
    } else {
        NSMutableData *data = [task.xl_data copy];
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *result = [self dictToString:obj];
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
        NSString *statusCodeStr = [NSString stringWithFormat:@"%ld", statusCode];
        if (isExist) {
            sql = [NSString stringWithFormat:@"update 'RequestTable' set url='%@',method='%@',header='%@',statusCode='%@',respone='%@' where requestId='%@'", urlString, method, headers, statusCodeStr, result, task.xl_requestId];
        } else {
            sql = [NSString stringWithFormat:@"insert into 'RequestTable'(requestId, url,method,header,statusCode,respone) values('%@',%@','%@','%@','%@','%@')", task.xl_requestId, urlString, method, headers, statusCodeStr, result];
        }
    }
    
    BOOL success = [self baseUpdateSql:sql];
    return success;
}

- (NSString *)dictToString:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"Error converting dictionary to JSON: %@", error.localizedDescription);
        return @"";
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

///request exsit
- (BOOL)isRequestExsit:(NSURLSessionTask *)task {
    NSString *sql = [NSString stringWithFormat:@"select COUNT(*) from RequestTable where requestId='%@'", task.xl_requestId];
    [self.db open];
    FMResultSet *result = [self.db executeQuery:sql];
    int count = 0;
    while ([result next]) {
        count = [result intForColumnIndex:0];
    }
    [self.db close];
    return count > 0;
}

///query request
- (NSArray *)queryAllRequests:(NSInteger)pageSize {
    NSString *order = @"ORDER BY ID DESC";
    NSInteger limitSize = LimitSize;
    NSString *sql = [NSString stringWithFormat:@"select * from 'RequestTable' %@ limit %ld offset %ld", order, limitSize, pageSize*limitSize];
    [self.db open];
    FMResultSet *result = [self.db executeQuery:sql];
    NSMutableArray *arr = [NSMutableArray array];
    while ([result next]) {
        XLRequestMode *mode = [XLRequestMode new];
        mode.requestId = [result stringForColumn:@"requestId"];
        mode.url = [result stringForColumn:@"url"];
        mode.method = [result stringForColumn:@"method"];
        mode.header = [result stringForColumn:@"header"];
        mode.body = [result stringForColumn:@"body"];
        mode.statusCode = [result stringForColumn:@"statusCode"];
        mode.respone = [result stringForColumn:@"respone"];
        [arr addObject:mode];
    }
    [self.db close];
    return [arr copy];
}

@end
