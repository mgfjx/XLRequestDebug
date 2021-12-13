//
//  NSURLSessionDataTask+Debug.h
//  TaiTelevision
//
//  Created by mgfjx on 2021/12/11.
//  Copyright © 2021 mgfjx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (Debug)

#ifdef DEBUG
@property (nonatomic, strong) NSMutableData *xl_data ;
#else
#endif

@end

NS_ASSUME_NONNULL_END
