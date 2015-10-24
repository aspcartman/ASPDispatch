//
// Created by ASPCartman on 22/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "ASPDispatch.h"

static BOOL containsSubString(NSArray *who, NSArray *what)
{
	for (NSString *string in who)
	{
		for (NSString *subString in what)
		{
			if ([string rangeOfString:subString].location != NSNotFound)
			{
				return YES;
			}
		}
	}
	return NO;
}



void __ASP_DISPATCH__(void(^block)()){
	block();
}

void ASPDispatchBlock(void(^routine)())
{
	CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, ^{
		__ASP_DISPATCH__(routine);
	});
}

BOOL ASPDispatchIsSafeToWait()
{
	static NSArray         *mustNotPresent;
	static NSArray         *mustPresent;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		mustNotPresent = @[ @"__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__" ];
		mustPresent    = @[ @"__ASP_DISPATCH__" ];
	});

	NSArray *stackSymbols = [NSThread callStackSymbols];

	return containsSubString(stackSymbols, mustPresent) && !containsSubString(stackSymbols, mustNotPresent);
}

void ASPDispatchWait(BOOL (^completionCheck)())
{
	if (!ASPDispatchIsSafeToWait())
	{
		NSLog(@"ASPDispatch: Warning, the queue may get blocked! If you see this warning, then you should call the code throwing it inside ASPDispatchBlock() block. %@", [NSThread callStackSymbols]);
	}

	while (!completionCheck())
	{
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, true);
	}
}

