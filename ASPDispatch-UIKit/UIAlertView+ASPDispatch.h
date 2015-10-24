//
// Created by ASPCartman on 23/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASPFuture;

@interface UIAlertView (ASPDispatch)
+ (ASPFuture *) asp_showWithTitle:(NSString*)title message:(NSString*)message cancelButton:(NSString*)cancel otherButtons:(NSArray*)other;
@end