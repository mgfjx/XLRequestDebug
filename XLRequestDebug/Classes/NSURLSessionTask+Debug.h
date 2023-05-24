//
//  NSURLSessionDataTask+Debug.h
//  TaiTelevision
//
//  Created by mgfjx on 2021/12/11.
//  Copyright © 2021 mgfjx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (Debug)

@property (nonatomic, strong) NSMutableData *xl_data ;
@property (nonatomic, strong) NSString *xl_requestId ;

@end

NS_ASSUME_NONNULL_END
