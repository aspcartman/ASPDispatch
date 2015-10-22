//
// Created by ASPCartman on 22/10/15.
// Copyright (c) 2015 aspcartman. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "ASPPromise.h"
#import "Common.h"
#import "ASPFuture.h"

SpecBegin(Future)
	__block ASPPromise *p;
	void(^nothing)(ASPPromise *) = ^(ASPPromise *p){};
	void(^done)(ASPPromise *) = ^(ASPPromise *p){p.result = @(0);};
	void(^error)(ASPPromise *) = ^(ASPPromise *p){p.error = (id) @(0);};



SpecEnd