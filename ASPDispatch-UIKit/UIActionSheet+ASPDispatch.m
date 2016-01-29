//
// Created by ASPCartman on 29/01/16.
// Copyright (c) 2016 ASPCartman. All rights reserved.
//

#import "UIActionSheet+ASPDispatch.h"
#import "ASPFuture.h"
#import "ASPDispatchUIKitHelpers.h"
#import "UIAlertController+ASPDispatch.h"
#import "ASPDynamicDelegate.h"

@implementation UIActionSheet (ASPDispatch)
+ (ASPFuture *) asp_showWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel otherButtons:(NSArray *)other
{
	if (ASPDispatchOSVersionIsBelow(@"8.0"))
	{
		return [ASPFuture inlineFuture:^(ASPPromise *p) {
			// iOS 7 and below
			ASPDynamicDelegate *d = [ASPDynamicDelegate new];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			[d addMethodForSelector:@selector(actionSheet:didDismissWithButtonIndex:) withBlock:^(id s, id ss, NSInteger index) {
				if (index)
				{
					p.result = @(index);
				}
				else
				{
					p.error = [[NSError alloc] initWithDomain:@"ASPDispatch" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"User canceled" }];
				}
			}];
#pragma clang diagnostic pop
			__unsafe_unretained id otherArgs[other.count];
			[other getObjects:otherArgs];
#pragma clang diagnostic push
#pragma ide diagnostic ignored "LastArgumentMustBeNull"
			UIActionSheet *view = [[UIActionSheet alloc] initWithTitle:title
			                                                  delegate:d
			                                         cancelButtonTitle:cancel ? : other ? NSLocalizedString(@"Cancel", nil) : NSLocalizedString(@"Dismiss", nil)
			                                    destructiveButtonTitle:nil
			                                         otherButtonTitles:*otherArgs];
#pragma clang diagnostic pop
			for (NSString *otherButton in other)
			{
				[view addButtonWithTitle:otherButton];
			}

			[view showInView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
		}];
	}
	else
	{
		return [UIAlertController asp_showWithStyle:UIAlertControllerStyleActionSheet title:title message:message cancelButton:cancel otherButtons:other];
	}
	return nil;
}
@end