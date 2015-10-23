//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "ASPFuture.h"
#import "ASPDispatch.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
typedef NS_ENUM(NSInteger, ASPFutureType)
{
	ASPFutureTypeInline = 0,
	ASPFutureTypeDispatch = 1,
	ASPFutureTypeAsync = 2,
};

@implementation ASPFuture
{
	ASPPromise       *_promise;
	ASPFutureType    _type;
	dispatch_queue_t _queue;

	void(^_block)(ASPPromise *);
}

@dynamic result;
@dynamic error;
@dynamic done;

#pragma mark Create

+ (instancetype) future:(void (^)(ASPPromise *p))block
{
	return [self inlineFuture:block];
}

+ (instancetype) inlineFuture:(void (^)(ASPPromise *p))block
{
	return [self futureWithPromise:[ASPPromise new] type:ASPFutureTypeInline queue:nil block:block];
}

+ (instancetype) routineFuture:(void (^)(ASPPromise *p))block
{
	return [self futureWithPromise:[ASPPromise new] type:ASPFutureTypeDispatch queue:nil block:block];
}

+ (instancetype) mainFuture:(void (^)(ASPPromise *p))block
{
	return [self asyncFutureOnQueue:dispatch_get_main_queue() block:block];
}

+ (instancetype) asyncFuture:(void (^)(ASPPromise *p))block
{
	return [self asyncFutureOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) block:block];
}

+ (instancetype) asyncFutureOnQueue:(dispatch_queue_t)queue block:(void (^)(ASPPromise *p))block
{
	return [self futureWithPromise:[ASPPromise new] type:ASPFutureTypeAsync queue:queue block:block];
}

+ (instancetype) futureWithPromise:(ASPPromise *)promise type:(ASPFutureType)type queue:(dispatch_queue_t)queue block:(void (^)(ASPPromise *))block
{
	ASPFuture *future = [self alloc];
	future->_block   = block;
	future->_promise = promise;
	future->_queue   = queue;
	future->_type    = type;

	[future run];

	return future;
}

#pragma mark Do Stuff

- (void) run
{
	switch (_type)
	{
		case ASPFutureTypeInline:
		{
			_block(_promise);
			break;
		}
		case ASPFutureTypeDispatch:
		{
			ASPDispatchBlock(^{
				_block(_promise);
			});
			break;
		}
		case ASPFutureTypeAsync:
		{
			dispatch_async(_queue, ^{
				_block(_promise);
			});
			break;
		}
	}
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
	return [ASPFuture futureWithPromise:[ASPPromise new] type:ASPFutureTypeInline queue:nil block:^(ASPPromise *promise) {
		for (NSUInteger i = 0; i < times && block(_promise); i++)
		{
			[_promise invalidate];
			[self run];
		}
		[promise merge:_promise];
	}];
}

#pragma mark Proxy

+ (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	return [ASPPromise methodSignatureForSelector:sel];
}

+ (void) forwardInvocation:(NSInvocation *)invocation
{
	[invocation invokeWithTarget:[ASPPromise class]];
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
#pragma clang diagnostic pop