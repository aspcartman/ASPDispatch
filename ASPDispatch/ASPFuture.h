//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASPPromise.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@interface ASPFuture<T> : NSProxy
@property (nonatomic, readonly) T       result;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) BOOL    done;

// Defaults to inline future
+ (instancetype) future:(void (^)(ASPPromise *p))block;

// Inline future's block will be called right inside this method.
// Usefull for wrapping usual async code with callbacks.
+ (instancetype) inlineFuture:(void (^)(ASPPromise *p))block;

// Async future dispatches the block on the default global queue.
+ (instancetype) asyncFuture:(void (^)(ASPPromise *p))block;

// Async future dispatches the block on the provided queue.
+ (instancetype) asyncFutureOnQueue:(dispatch_queue_t)queue block:(void (^)(ASPPromise *p))block;

// Routine future dispatches a block using ASPDispatchBlock function.
+ (instancetype) routineFuture:(void (^)(ASPPromise *p))block;

+ (void) wait:(NSArray<ASPFuture *> *)futures;

- (void) wait;
- (instancetype) retryOnErrorOnce;
- (instancetype) retryOnError:(NSUInteger)times;
- (instancetype) retryTimes:(NSUInteger)times while:(BOOL(^)(ASPPromise *))block;
@end

#pragma clang diagnostic pop