//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "ASPFuture.h"
#import "ASPDispatch.h"

@implementation ASPFuture
{
	ASPPromise *_promise;
}

@dynamic result;
@dynamic error;
@dynamic done;

+ (instancetype) future:(void (^)(ASPPromise *p))block
{
	return [self inlineFuture:block];
}

+ (instancetype) inlineFuture:(void (^)(ASPPromise *p))block
{
	ASPPromise *promise = [ASPPromise new];
	block(promise);

	return [self futureWithPromise:promise];
}

+ (instancetype) routineFuture:(void (^)(ASPPromise *p))block
{
	ASPPromise *promise = [ASPPromise new];
	ASPDispatchBlock(^{
		block(promise);
	});

	return [self futureWithPromise:promise];
}

+ (instancetype) mainFuture:(void (^)(ASPPromise *p))block
{
	ASPPromise *promise = [ASPPromise new];
	ASPDispatchBlock(^{
		block(promise);
	});

	return [self futureWithPromise:promise];
}

+ (instancetype) asyncFuture:(void (^)(ASPPromise *p))block
{
	return [self asyncFutureOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) block:block];
}

+ (instancetype) asyncFutureOnQueue:(dispatch_queue_t)queue block:(void (^)(ASPPromise *p))block
{
	ASPPromise *promise = [ASPPromise new];
	dispatch_async(queue, ^{
		block(promise);
	});

	return [self futureWithPromise:promise];
}

+ (instancetype) futureWithPromise:(ASPPromise *)promise
{
	ASPFuture *future = [self alloc];
	future->_promise = promise;
	return future;
}


- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	return [_promise methodSignatureForSelector:sel];
}

- (void) forwardInvocation:(NSInvocation *)invocation
{
	[invocation invokeWithTarget:_promise];
}
@end