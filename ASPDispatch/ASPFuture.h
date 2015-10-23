//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASPPromise.h"

@interface ASPFuture
<T> : NSProxy
@property (nonatomic, readonly) T       result;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) BOOL    done;


+ (instancetype) future:(void (^)(ASPPromise *p))block;

/*
 *  Inline future's block will be called right inside
 *  this method.
 *  Usefull for wrapping usual async code with callbacks.
 *
 * */
+ (instancetype) inlineFuture:(void (^)(ASPPromise *p))block;


/*
 * Async future dispatches the block on the default global queue.
 */
+ (instancetype) asyncFuture:(void (^)(ASPPromise *p))block;

/*
 * Async future dispatches the block on the provided queue.
 */
+ (instancetype) asyncFutureOnQueue:(dispatch_queue_t)queue block:(void (^)(ASPPromise *p))block;

/*
 * Routine future dispatches a block using ASPDispatchBlock function.
 */
+ (instancetype) routineFuture:(void (^)(ASPPromise *p))block;

+ (instancetype) futureWithPromise:(ASPPromise *)promise;
@end


