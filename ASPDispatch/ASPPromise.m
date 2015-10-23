//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "ASPPromise.h"
#import "ASPDispatch.h"

/*
 * Class cluster
 */

@interface ASPPromiseBlocker : ASPPromise
@end

@interface ASPPromiseRunLoopSpinner : ASPPromise
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wreceiver-forward-class"

@implementation ASPPromise
@dynamic result;
@dynamic error;

+ (instancetype) alloc
{
	if (self == [ASPPromise class])
	{
		return [NSThread isMainThread] ? [ASPPromiseRunLoopSpinner alloc] : [ASPPromiseBlocker alloc];
	}
	return [self allocWithZone:nil]; // Needs explanation
}

+ (instancetype) promise
{
	return [self new];
}

+ (instancetype) blockingPromise
{
	return [ASPPromiseBlocker new];
}

+ (instancetype) runLoopingPromise
{
	return [ASPPromiseRunLoopSpinner new];
}
@end

#pragma clang diagnostic pop

@implementation ASPPromiseBlocker
{
	id      _result;
	NSError *_error;

	dispatch_group_t _group;
}

- (instancetype) init
{
	self = [super init];
	if (self)
	{
		dispatch_group_t group = dispatch_group_create();
		dispatch_group_enter(group);
		_group                 = group;
	}
	return self;
}

- (void) dealloc
{
	// Avoid EXC_BAD_INSTRUCTION, emptify the group!
	if (dispatch_group_wait(_group, DISPATCH_TIME_NOW) != 0)
	{
		dispatch_group_leave(_group);
	}
}

- (id) result
{
	NSParameterAssert(![NSThread isMainThread]);
	dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
	return _result;
}

- (void) setResult:(id)result
{
	NSParameterAssert(result);
	NSParameterAssert(![NSThread isMainThread]);
	NSParameterAssert(_result == nil && _error == nil);
	_result = result;
	dispatch_group_leave(_group);
}

- (NSError *) error
{
	NSParameterAssert(![NSThread isMainThread]);
	dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
	return _error;
}

- (void) setError:(NSError *)error
{
	NSParameterAssert(error);
	NSParameterAssert(![NSThread isMainThread]);
	NSParameterAssert(_result == nil && _error == nil);
	_error = error;
	dispatch_group_leave(_group);
}

- (BOOL) done
{
	NSParameterAssert(![NSThread isMainThread]);
	return dispatch_group_wait(_group, DISPATCH_TIME_NOW) == 0;
}
@end


@implementation ASPPromiseRunLoopSpinner
{
	id      _result;
	NSError *_error;

	dispatch_semaphore_t _sema;
}

- (instancetype) init
{
	self = [super init];
	if (self)
	{
		_sema = dispatch_semaphore_create(1);
	}

	return self;
}

- (id) result
{
	[self wait];
	return _result;
}

- (void) setResult:(id)result
{
	NSParameterAssert(result);
	NSParameterAssert(_result == nil && _error == nil);
	_result = result;
}

- (NSError *) error
{
	[self wait];
	return _error;
}

- (void) setError:(NSError *)error
{
	NSParameterAssert(error);
	NSParameterAssert(_result == nil && _error == nil);
	_error = error;
}

- (BOOL) done
{
	return _result != nil || _error != nil;
}

- (void) wait
{
	ASPDispatchWait(^{
		return [self done];
	});
}
@end