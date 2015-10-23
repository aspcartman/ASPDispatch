#import "Specta.h"
#import "Expecta.h"
#import "ASPPromise.h"
#import "Common.h"

/*
 * Tests are expected to be executed serially
 * since of a singletone pointer usage for simplicity
 * sake. They are also expected to be executed on the
 * main thread since ASPPromiseBlocker tests assume so.
 */

SpecBegin(Promise)
	__block ASPPromise *p;

	describe(@"ClassCluster", ^{
		it(@"Creates a ASPPromiseRunLoopSpinner by default on main thread", ^{
			run(NO, ^{
				expect([ASPPromise new]).to.beInstanceOf(NSClassFromString(@"ASPPromiseRunLoopSpinner"));
			});
		});

		it(@"Creates a ASPPromiseBlocker by default on background thread", ^{
			run(YES, ^{
				expect([ASPPromise new]).to.beInstanceOf(NSClassFromString(@"ASPPromiseBlocker"));
			});
		});

		it(@"Creates a requested promise on main thread and background", ^{
			run(NO, ^{
				expect([ASPPromise runLoopingPromise]).to.beInstanceOf(NSClassFromString(@"ASPPromiseRunLoopSpinner"));
				expect([ASPPromise blockingPromise]).to.beInstanceOf(NSClassFromString(@"ASPPromiseBlocker"));
			});
			run(YES, ^{
				expect([ASPPromise runLoopingPromise]).to.beInstanceOf(NSClassFromString(@"ASPPromiseRunLoopSpinner"));
				expect([ASPPromise blockingPromise]).to.beInstanceOf(NSClassFromString(@"ASPPromiseBlocker"));
			});
		});
	});

	sharedExamples(@"Common", ^(NSDictionary *data) {
		BOOL background = [data[@"background"] boolValue];
		id(^generator)() = data[@"object"];
		beforeEach(^{
			p = generator();
		});

		it(@"Is subclass of ASPPromise", ^{
			run(background, ^{
				expect(p).to.beKindOf([ASPPromise class]);
				expect(p).notTo.beInstanceOf([ASPPromise class]);
			});
		});

		it(@"Initially not done", ^{
			run(background, ^{
				expect(p.done).to.equal(0);
			});
		});

		it(@"Sets done on result", ^{
			run(background, ^{
				p.result = @(0);
				expect(p.done).to.beTruthy();
			});
		});

		it(@"Sets done on error", ^{
			run(background, ^{
				p.error = (id) @(0);
				expect(p.done).to.beTruthy();
			});
		});

		it(@"Allows setting nil result", ^{
			run(background, ^{
				expect(^{
					p.result = nil;
				}).toNot.raiseAny();
			});
		});

		it(@"Allows setting nil error", ^{
			run(background, ^{
				expect(^{
					p.error = nil;
				}).toNot.raiseAny();
			});
		});

		it(@"Allows setting nil result after set error", ^{
			run(background, ^{
				p.error = (id)@(0);
				expect(^{
					p.result = nil;
				}).toNot.raiseAny();
			});
		});

		it(@"Allows setting nil error after set result", ^{
			run(background, ^{
				p.result = @(0);
				expect(^{
					p.error = nil;
				}).toNot.raiseAny();
			});
		});

		it(@"Throws on niling result", ^{
			run(background, ^{
				p.result = @(0);
				expect(^{
					p.result = nil;
				}).to.raiseAny();
			});
		});

		it(@"Throws on niling error", ^{
			run(background, ^{
				p.error = (id) @(0);
				expect(^{
					p.error = nil;
				}).to.raiseAny();
			});
		});

		it(@"Throws on second result set", ^{
			run(background, ^{
				p.result = @(1);
				expect(^{
					p.result = @(0);
				}).to.raiseAny();
			});
		});

		it(@"Throws on second error set", ^{
			run(background, ^{
				p.error = (id) @(1); //
				expect(^{
					p.error = (id) @(0);
				}).to.raiseAny();
			});
		});

		it(@"Throws on error after result set", ^{
			run(background, ^{
				p.result = @(1); //
				expect(^{
					p.error = (id) @(0);
				}).to.raiseAny();
			});
		});

		it(@"Throws on result after error set", ^{
			run(background, ^{
				p.error = (id) @(1); //
				expect(^{
					p.result = @(0);
				}).to.raiseAny();
			});
		});

		it(@"Waits for result", ^{
			run(background, ^{
				NSDate *start = [NSDate new];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), background ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) : dispatch_get_main_queue(), ^{
					p.result = @(0);
				});
				expect(p.result).to.equal(@(0));
				expect([[NSDate new] timeIntervalSinceDate:start]).to.beGreaterThanOrEqualTo(1.0f);
			});
		});

		it(@"Waits for error", ^{
			run(background, ^{
				NSDate *start = [NSDate new];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), background ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) : dispatch_get_main_queue(), ^{
					p.error = (id) @(0);
				});
				expect(p.error).to.equal(@(0));
				expect([[NSDate new] timeIntervalSinceDate:start]).to.beGreaterThanOrEqualTo(1.0f);
			});
		});
	});

	sharedExamplesFor(@"Promise In Background", ^(NSDictionary *data) {
		itShouldBehaveLike(@"Common", @{ @"background" : @(YES), @"object" : data[@"object"] });
	});

	sharedExamplesFor(@"Promise On MainThread", ^(NSDictionary *data) {
		itShouldBehaveLike(@"Common", @{ @"background" : @(NO), @"object" : data[@"object"] });
	});

	describe(@"Blocker", ^{
		itShouldBehaveLike(@"Promise In Background", @{ @"object" : ^{
			return [ASPPromise blockingPromise];
		} });

		beforeEach(^{
			p = [ASPPromise blockingPromise];
		});

		it(@"Throws on result access on main thread", ^{
			run(NO, ^{
				expect(^{
					p.result;
				}).to.raiseAny();
				expect(^{
					p.result = @(0);
				}).to.raiseAny();
			});
		});

		it(@"Throws on error access on main thread", ^{
			run(NO, ^{
				expect(^{
					p.error;
				}).to.raiseAny();
				expect(^{
					p.error = @(0);
				}).to.raiseAny();
			});
		});

		it(@"Throws on done access on main thread", ^{
			run(NO, ^{
				expect(^{
					p.done;
				}).to.raiseAny();
			});
		});
	});

	describe(@"RunLooper", ^{
		itShouldBehaveLike(@"Promise In Background", @{ @"object" : ^{
			return [ASPPromise runLoopingPromise];
		} });
		itShouldBehaveLike(@"Promise On MainThread", @{ @"object" : ^{
			return [ASPPromise runLoopingPromise];
		} });
	});
SpecEnd
