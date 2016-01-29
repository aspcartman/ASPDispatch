//
// Created by ASPCartman on 29/01/16.
// Copyright (c) 2016 ASPCartman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASPFuture;

@interface UIActionSheet (ASPDispatch)
+ (ASPFuture *) asp_showWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel otherButtons:(NSArray*)other;
@end