//
// Created by ASPCartman on 22/10/15.
// Copyright (c) 2015 aspcartman. All rights reserved.
//

#import "ASPDispatch.h"
static BOOL containsSubString(NSArray *who, NSArray *what);


void ASPDispatchBlock(void(^routine)())
{
	CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, ^{
		routine();
	});
}

BOOL ASPDispatchIsSafeToWait()
{
	static NSArray *mustNotPresent;
	static NSArray *mustPresent;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		mustNotPresent = @[@"__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__"];
		mustPresent = @[@"__CFRUNLOOP_IS_SERVICING_THE_ASP_DISPATCH__"];
	});

	NSArray       *stackSymbols = [NSThread callStackSymbols];

	return containsSubString(stackSymbols, mustPresent) && !containsSubString(stackSymbols, mustNotPresent);
}

void ASPDispatchWait(BOOL (^completionCheck)())
{
	NSCParameterAssert(ASPDispatchIsSafeToWait());
	
	while (!completionCheck())
	{
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, true);
	}
}


static BOOL containsSubString(NSArray *who, NSArray *what)
{
	for (NSString *string in who) {
		for (NSString *subString in what){
			if ([string rangeOfString:subString].location != NSNotFound){
				return YES;
			}
		}
	}
	return NO;
}