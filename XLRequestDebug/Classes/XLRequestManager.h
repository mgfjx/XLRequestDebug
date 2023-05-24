//
//  XLRequestManager.h
//  XLRequestDebug
//
//  Created by mgfjx on 2023/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLRequestManager : NSObject

/// 是否启用拦截，重启后生效
@property (nonatomic, assign) BOOL enable ;

+ (instancetype)shared ;

@end

NS_ASSUME_NONNULL_END
