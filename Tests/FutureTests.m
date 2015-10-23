//
// Created by ASPCartman on 22/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "Specta.h"
#import "ASPPromise.h"

SpecBegin(Future)
	__block ASPPromise *p;
	void(^nothing)(ASPPromise *) = ^(ASPPromise *p) {
	};
	void(^done)(ASPPromise *)    = ^(ASPPromise *p) {
		p.result = @(0);
	};
	void(^error)(ASPPromise *)   = ^(ASPPromise *p) {
		p.error = (id) @(0);
	};
SpecEnd