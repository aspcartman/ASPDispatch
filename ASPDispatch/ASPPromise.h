//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@interface ASPPromise<T> : NSObject
@property (nonatomic, strong) T       result;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, readonly) BOOL  done;

+ (instancetype) promise; // Same as -new
+ (instancetype) blockingPromise;
+ (instancetype) runLoopingPromise;
+ (void) wait:(NSArray<ASPPromise *> *)promises;

- (void) wait;
- (void) invalidate;
- (void) merge:(ASPPromise *)otherPromise;
@end

#pragma clang diagnostic pop