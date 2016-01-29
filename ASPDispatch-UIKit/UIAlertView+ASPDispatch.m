//
// Created by ASPCartman on 23/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "UIAlertView+ASPDispatch.h"
#import "ASPFuture.h"
#import "ASPDynamicDelegate.h"
#import "ASPDispatchUIKitHelpers.h"
#import "UIAlertController+ASPDispatch.h"

@implementation UIAlertView (ASPDispatch)
+ (ASPFuture *) asp_showWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel otherButtons:(NSArray *)other
{
	if (ASPDispatchOSVersionIsBelow(@"8.0"))
	{
		return [ASPFuture inlineFuture:^(ASPPromise *p) {
			// iOS 7 and below
			ASPDynamicDelegate *d = [ASPDynamicDelegate new];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			[d addMethodForSelector:@selector(alertView:clickedButtonAtIndex:) withBlock:^(id s, id ss, NSInteger index) {
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
			UIAlertView   *view = [[UIAlertView alloc] initWithTitle:title
			                                                 message:message
			                                                delegate:d
			                                       cancelButtonTitle:cancel ? : other ? NSLocalizedString(@"Cancel", nil) : NSLocalizedString(@"Dismiss", nil)
			                                       otherButtonTitles:nil];
			for (NSString *otherButton in other)
			{
				[view addButtonWithTitle:otherButton];
			}

			[view show];
		}];
	}
	else
	{
		return [UIAlertController asp_showWithStyle:UIAlertControllerStyleAlert title:title message:message cancelButton:cancel otherButtons:other];
	}
}
@end