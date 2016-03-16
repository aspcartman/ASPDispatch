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
+ (ASPFuture *) asp_showFromView:(UIView *)view withTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel otherButtons:(NSArray *)other;
{
	if (ASPDispatchOSVersionIsBelow(@"8.0"))
	{
		return [ASPFuture inlineFuture:^(ASPPromise *p) {
			NSString *cancelTitle      = cancel ? : other ? NSLocalizedString(@"Cancel", nil) : NSLocalizedString(@"Dismiss", nil);

			// iOS 7 and below
			__block ASPDynamicDelegate     *d = [ASPDynamicDelegate new];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			[d addMethodForSelector:@selector(actionSheet:didDismissWithButtonIndex:) withBlock:^(id s, UIActionSheet * ss, NSInteger index) {
				if (![[ss buttonTitleAtIndex:index] isEqualToString:cancelTitle])
				{
					p.result = @([other indexOfObject:[ss buttonTitleAtIndex:index]]+1);
				}
				else
				{
					p.error = [[NSError alloc] initWithDomain:@"ASPDispatch" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"User canceled" }];
				}
				d = nil;
			}];
#pragma clang diagnostic pop

			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
			                                                         delegate:(id <UIActionSheetDelegate>) d
			                                                cancelButtonTitle:nil
			                                           destructiveButtonTitle:nil
			                                                otherButtonTitles:nil];
			for (NSString *otherButton in other)
			{
				[actionSheet addButtonWithTitle:otherButton];
			}
			[actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:cancelTitle]];

			UIView *rootView = [UIApplication sharedApplication].delegate.window.rootViewController.view;
			if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
			{
				[actionSheet showFromRect:[rootView convertRect:view.frame fromView:view.superview] inView:rootView animated:YES];
			} else {
				[actionSheet showInView:rootView];
			}
		}];
	}
	else
	{

		return [UIAlertController asp_showWithStyle:UIAlertControllerStyleActionSheet fromView:view title:title message:message cancelButton:cancel otherButtons:other];
	}
	return nil;
}
@end