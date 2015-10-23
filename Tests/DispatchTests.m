//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "Specta.h"
#import "ASPDispatch.h"

static void runloopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

SpecBegin(RunLoop)
it(@"Let's look on fds", ^{
BOOL                 *ptr        = &done;
CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runloopObserverCallback, NULL);
CFRunLoopAddObserver(CFRunLoopGetCurrent(), observerRef, kCFRunLoopCommonModes
);

for (
int i = 0;
i < 10; ++i)
{
NSLog(@"Dispatcher");
dispatch_async(dispatch_get_main_queue(), ^
{
*
ptr = NO;
NSLog(@"MAIN! %d", i);
//					[[NSRunLoop currentRunLoop] performSelector:@selector(print) target:[TestHelper new] argument:nil order:0 modes:@[NSDefaultRunLoopMode]];
//					id t = [NSTimer scheduledTimerWithTimeInterval:0.0 target:[TestHelper new] selector:@selector(print) userInfo:nil repeats:NO];
ASPDispatchBlock(^{
NSLog(@"DispatchedInMain %d", i);
});
});
ASPDispatchBlock(^{
NSLog(@"DispatchedInDispatcher %d", i);
});
}
ASPDispatchBlock(^{
NSLog(@"AfterDispatcher");
});

waitUntil(^(DoneCallback
_done) {
if (*ptr)
{
_done();
}
});
});

it(@"Dispatches", ^{
ASPDispatchBlock(^{
NSLog(@"2");
});
NSLog(@"1");
});

SpecEnd

static void runloopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
	CFRunLoopActivity currentActivity = activity;
	switch (currentActivity)
	{
		case kCFRunLoopEntry:
			NSLog(@"kCFRunLoopEntry \n");
			break;

		case kCFRunLoopBeforeTimers:
			NSLog(@"kCFRunLoopBeforeTimers \n");
			break;

		case kCFRunLoopBeforeSources:
			NSLog(@"kCFRunLoopBeforeSources \n");
			break;

		case kCFRunLoopBeforeWaiting:
			NSLog(@"kCFRunLoopBeforeWaiting \n");
			break;

		case kCFRunLoopAfterWaiting:
			NSLog(@"kCFRunLoopAfterWaiting \n");
			break;

		case kCFRunLoopExit:
			NSLog(@"kCFRunLoopExit \n");
			break;

		default:
			NSLog(@"Activity not recognized!\n");
			break;
	}
}