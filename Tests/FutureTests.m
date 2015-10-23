//
// Created by ASPCartman on 22/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "Specta.h"
#import "ASPPromise.h"
#import "ASPFuture.h"
#import "Expecta.h"

SpecBegin(Future)
	__block ASPFuture *f;
	void(^nothing)(ASPPromise *) = ^(ASPPromise *p) {
	};
	void(^done)(ASPPromise *)    = ^(ASPPromise *p) {
		p.result = @(0);
	};
	void(^error)(ASPPromise *)   = ^(ASPPromise *p) {
		p.error = (id) @(0);
	};

	describe(@"Retry",^{
		it(@"Retries once", ^{
			__block int count = 0;
			f = [[ASPFuture future:^(ASPPromise *p){
				count++;
				p.error = (id) @(0);
			}] retryOnErrorOnce];
			expect(count).to.equal(2);
		});
	});
SpecEnd