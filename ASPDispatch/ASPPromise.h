//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 aspcartman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASPPromise <T> : NSObject
@property (nonatomic, strong) T       result;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, readonly) BOOL  done;

+ (instancetype) promise; // Same as -new
+ (instancetype) blockingPromise;
+ (instancetype) runLoopingPromise;
@end