//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "ASPFuture.h"
#import "ASPDispatch.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@interface ASPFutureInline : ASPFuture
+ (instancetype) futureWithBlock:(void (^)(ASPPromise *p))block;
@end

@interface ASPFutureDispatch : ASPFuture
+ (instancetype) futureWithBlock:(void (^)(ASPPromise *p))block;
@end

@interface ASPFutureAsync : ASPFuture
+ (instancetype) futureOnQueue:(dispatch_queue_t)queue withBlock:(void (^)(ASPPromise *))block;
@end

@interface ASPFutureOnDemand : ASPFuture
@end

@implementation ASPFuture
{
@package
	ASPPromise *_promise;
	void(^_block)(ASPPromise *);
}

@dynamic result;
@dynamic error;
@dynamic done;
@dynamic promise;

#pragma mark Create

/*
 * Those methods is what public use to get access to specific subclasses
 */
+ (instancetype) inlineFuture:(void (^)(ASPPromise *p))block
{
	return [ASPFutureInline futureWithBlock:block];
}

+ (instancetype) onDemandFuture:(void (^)(ASPPromise *p))block
{
	return [ASPFutureOnDemand futureWithBlock:block];
}

+ (instancetype) dispatchFuture:(void (^)(ASPPromise *p))block
{
	return [ASPFutureDispatch futureWithBlock:block];
}

+ (instancetype) future:(void (^)(ASPPromise *p))block
{
	return [ASPFutureDispatch futureWithBlock:block];
}

+ (instancetype) mainFuture:(void (^)(ASPPromise *p))block
{
	return [ASPFutureAsync futureOnQueue:dispatch_get_main_queue() withBlock:block];
}

+ (instancetype) asyncFuture:(void (^)(ASPPromise *p))block
{
	return [ASPFutureAsync futureOnQueue:dispatch_get_main_queue() withBlock:block];
}

+ (instancetype) asyncFutureOnQueue:(dispatch_queue_t)queue block:(void (^)(ASPPromise *p))block
{
	return [ASPFutureAsync futureOnQueue:queue withBlock:block];
}

+ (id) alloc
{
	if ([self class] == [ASPFuture class])
	{
		NSAssert(0, @"Do not call +alloc -init or +new on me, use + *Future: methods && -initWithBlock:.");
		return nil;
	}
	return [self allocWithZone:nil];
}

#pragma mark Initializer

+ (instancetype) futureWithBlock:(void (^)(ASPPromise *p))block
{
	ASPFuture *future = [[self alloc] init]; // This will be called by subclasses only, so superclass is ASPFuture.
	future->_promise = [ASPPromise new];
	future->_block   = block;
	return future;
}

#pragma mark Do Stuff

- (ASPPromise *) promise
{
	return _promise;
}

- (instancetype) retryOnErrorOnce
{
	return [self retryOnError:1];
}

- (instancetype) retryOnError:(NSUInteger)times
{
	return [self retryTimes:times while:^BOOL(ASPPromise *p) {
		return self.error != nil;
	}];
};

- (instancetype) retryTimes:(NSUInteger)times while:(BOOL(^)(ASPPromise *))block
{
	return [ASPFutureOnDemand futureWithBlock:^(ASPPromise *promise) {
		for (NSUInteger i = 0; i < times && block(_promise); i++)
		{
			[_promise invalidate];
			[self run];
		}
		[promise merge:_promise];
	}];
}

- (instancetype) map:(void (^)(ASPPromise *out, ASPFuture *in))block
{
	return [ASPFutureOnDemand futureWithBlock:^(ASPPromise *promise) {
		block(promise, self);
	}];
}

- (void) run
{
	NSParameterAssert(0);
}

#pragma mark Proxy

- (id) forwardingTargetForSelector:(SEL)aSelector
{
	return _promise;
}
@end

#pragma clang diagnostic pop

#pragma mark Inline

@implementation ASPFutureInline
+ (instancetype) futureWithBlock:(void (^)(ASPPromise *p))block
{
	ASPFuture *future = [super futureWithBlock:block];
	[future run];
	return (ASPFutureInline *) future;
}

- (void) run
{
	_block(_promise);
}
@end

#pragma mark Dispatch

@implementation ASPFutureDispatch
+ (instancetype) futureWithBlock:(void (^)(ASPPromise *p))block
{
	ASPFuture *future = [super futureWithBlock:block];
	[future run];
	return (ASPFutureDispatch *) future;
}

- (void) run
{
	ASPDispatchBlock(^{
		_block(_promise);
	});
}
@end

#pragma mark Async

@implementation ASPFutureAsync
{
	dispatch_queue_t _queue;
}
+ (instancetype) futureWithBlock:(void (^)(ASPPromise *p))block
{
	NSAssert(0, @"Call +futureOnQueue:withBlock:");
	return nil;
}

+ (instancetype) futureOnQueue:(dispatch_queue_t)queue withBlock:(void (^)(ASPPromise *))block
{
	ASPFutureAsync *f = (ASPFutureAsync *) [super futureWithBlock:block];
	f->_queue = queue;
	[f run];
	return f;
}

- (void) run
{
	dispatch_async(_queue, ^{
		_block(_promise);
	});
}
@end

#pragma mark OnDemand

@implementation ASPFutureOnDemand
- (void) run
{
	if (!_promise.done)
	{
		_block(_promise);
	}
}

- (id) result
{
	[self run];
	return _promise.result;
}

- (NSError *) error
{
	[self run];
	return _promise.error;
}

- (void) wait
{
	[self run];
	[_promise wait];
}
@end
