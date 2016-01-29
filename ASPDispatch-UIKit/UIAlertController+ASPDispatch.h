//
// Created by ASPCartman on 24/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASPFuture;

@interface UIAlertController (ASPDispatch)
+ (ASPFuture *) asp_showWithStyle:(UIAlertControllerStyle)style title:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel otherButtons:(NSArray *)other;
@end