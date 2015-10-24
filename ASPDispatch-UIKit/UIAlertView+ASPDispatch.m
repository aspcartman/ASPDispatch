//
// Created by ASPCartman on 23/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "UIAlertView+ASPDispatch.h"
#import "ASPFuture.h"
#import "ASPDynamicDelegate.h"
#import "ASPDispatchUIKitHelpers.h"

@implementation UIAlertView (ASPDispatch)
+ (ASPFuture *) asp_showWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel otherButtons:(NSArray *)other
{
	return [ASPFuture inlineFuture:^(ASPPromise *p) {
		if (ASPDispatchOSVersionIsBelow(@"8.0"))
		{
			// iOS 7 and below
			ASPDynamicDelegate *d = [ASPDynamicDelegate new];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			[d addMethodForSelector:@selector(alertView:clickedButtonAtIndex:) withBlock:^(id s, id ss, NSInteger index) {
				p.result = @(index);
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
		}
		else
		{
			UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
			[vc addAction:[UIAlertAction actionWithTitle:cancel ? : other ? NSLocalizedString(@"Cancel", nil) : NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
				p.result = @(0);
			}]];
			[other enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				[vc addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
					p.result = @(idx + 1);
				}]];
			}];
			[ASPDispatchCurrentViewController() presentViewController:vc animated:YES completion:nil];
		}
	}];
}
@end