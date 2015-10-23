//
// Created by ASPCartman on 21/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <dispatch/queue.h>
#import "Common.h"
#import "SpectaDSL.h"

void(^run)(BOOL, void(^)()) = ^void(BOOL background, void (^block)()) {
	if (!background)
	{
		block();
		return;
	}

	waitUntil(^(DoneCallback done) { // waitUntil spins the NSRunLoop for us
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			block();
			done();
		});
	});
};