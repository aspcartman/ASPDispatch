//
// Created by ASPCartman on 24/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//


#import "Specta.h"
#import "ASPDynamicDelegate.h"
#import "Expecta.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@interface ASPDynamicDelegate(ASPDynamicDelegateTests)
- (void) dummy;
- (void) dummyID:(id)lol;
- (id) idDummyID:(id)lol;
- (CGFloat) floatDummyID:(id)lol float:(CGFloat)f;
@end
#pragma clang diagnostic pop

SpecBegin(DynamicDelegate)
	fdescribe(@"Delegate", ^{
		ASPDynamicDelegate *d = [ASPDynamicDelegate delegate:^(ASPDynamicDelegate *delegate){ }];
		it(@"Adds an empty block", ^{
			__block BOOL done = NO;
			[d addMethodForSelector:@selector(dummy) withBlock:^{
				done = YES;
			}];
			[d dummy];
			expect(done).to.equal(YES);
		});
		pending(@"Adds a block with self argument", ^{
			__block id done = nil;
			[d addMethodForSelector:@selector(dummy) withBlock:^(id s){
				done = s;
			}];
			[d dummy];
			expect(done).to.equal(d);
		});
		it(@"Adds a selector, that takes an object argument", ^{
			__block id done = nil;
			[d addMethodForSelector:@selector(dummyID:) withBlock:^(id s, id arg){
				done = arg;
			}];
			[d dummyID:self];
			expect(done).to.equal(self);
		});
		it(@"Adds a selector that takse id returns id", ^{
			[d addMethodForSelector:@selector(idDummyID:) withBlock:^(id s, id arg){
				return arg;
			}];
			id res = [d idDummyID:self];
			expect(res).to.equal(self);
		});
		it(@"Adds a selector that takes id and float returns float", ^{
			[d addMethodForSelector:@selector(floatDummyID:float:) withBlock:^(id s, id arg1, CGFloat arg2){
				return arg2;
			}];
			CGFloat res = [d floatDummyID:self float:CGFLOAT_MAX];
			expect(res).to.equal(CGFLOAT_MAX);
		});
	});
SpecEnd