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

	describe(@"Retry", ^{
		it(@"Retries once", ^{
			__block int count = 0;
			f = [[ASPFuture inlineFuture:^(ASPPromise *p) {
				count++;
				p.error = (id) @(0);
			}] retryOnErrorOnce];
			f.result;
			expect(count).to.equal(2);
		});
	});

	describe(@"Mapping", ^{
		it(@"Maps", ^{
			f = [[ASPFuture inlineFuture:^(ASPPromise *p) {
				p.result = @(10);
			}] map:^(ASPPromise *p,ASPFuture *f) {
				p.result = @([f.result integerValue] + 5);
			}];
			expect(f.result).to.equal(@(15));
		});
		it(@"Map creation doesn't trigger future", ^{
			__block int count = 0;
			f = [[ASPFuture dispatchFuture:^(ASPPromise *p) {
				count++;
				p.result = @(10);
			}] map:^(ASPPromise *p, ASPFuture *f) {
				count++;
				p.result = @([f.result integerValue] + 5);
			}];
			expect(count).to.equal(0);
			expect(f.result).to.equal(@(15));
			expect(count).to.equal(2);
		});
	});
SpecEnd