//
//  XLDBManager.h
//  XLRequestDebug
//
//  Created by mgfjx on 2023/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLDBManager : NSObject

@property (nonatomic, strong) NSString *dbPath ;

+ (instancetype)manager;

///save request
- (BOOL)saveRequest:(NSURLSessionTask *)task ;

///save response
- (BOOL)saveResponse:(NSURLSessionTask *)task error:(NSError *)error ;

///query request
- (NSArray *)queryAllRequests:(NSInteger)pageSize ;

@end

NS_ASSUME_NONNULL_END
