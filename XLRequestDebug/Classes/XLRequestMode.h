//
//  XLRequestMode.h
//  XLRequestDebug
//
//  Created by mgfjx on 2023/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLRequestMode : NSObject

@property (nonatomic, strong) NSString *requestId ;
@property (nonatomic, strong) NSString *url ;

@property (nonatomic, strong) NSString *method ;
@property (nonatomic, strong) NSString *header ;
@property (nonatomic, strong) NSString *body ;
@property (nonatomic, strong) NSString *statusCode ;
@property (nonatomic, strong) NSString *respone ;

@end

NS_ASSUME_NONNULL_END
