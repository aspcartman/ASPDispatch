//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASPPromise.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@interface ASPFuture<T> : NSObject
@property (nonatomic, readonly) ASPPromise *promise;
@property (nonatomic, readonly) T          result;
@property (nonatomic, readonly) NSError    *error;
@property (nonatomic, readonly) BOOL       done;

/*
 * Inline future's block will be called right inside this method.
 * Usefull for wrapping usual async code with callbacks.
 */
+ (instancetype) inlineFuture:(void (^)(ASPPromise *p))block;

/*
 * Block will be called on -result, -error, -wait calls
 */
+ (instancetype) onDemandFuture:(void (^)(ASPPromise *p))block;

/*
 * Block will be dispatched on a global queue in this method
 */
+ (instancetype) asyncFuture:(void (^)(ASPPromise *p))block;

/*
 * Block will be dispatched on a main queue in this method
 */
+ (instancetype) mainFuture:(void (^)(ASPPromise *p))block;

/*
 * Block will be dispatched on the queue in this method
 */
+ (instancetype) asyncFutureOnQueue:(dispatch_queue_t)queue block:(void (^)(ASPPromise *p))block;

/*
 * Block will be dispatched with ASPDispatch in this runloop with this method
 */
+ (instancetype) dispatchFuture:(void (^)(ASPPromise *p))block;

/*
 * Defaults to +dispatchFuture:
 */
+ (instancetype) future:(void (^)(ASPPromise *p))block;


/*
 * Wait for multiple futures, sugar.
 */
+ (void) wait:(NSArray<ASPFuture *> *)futures;

- (void) wait;
- (instancetype) retryOnErrorOnce;
- (instancetype) retryOnError:(NSUInteger)times;
- (instancetype) retryTimes:(NSUInteger)times while:(BOOL(^)(ASPPromise *))block;
- (instancetype) map:(void (^)(ASPFuture *, ASPPromise *))block;
@end

#pragma clang diagnostic pop