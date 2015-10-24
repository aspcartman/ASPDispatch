//
// Created by ASPCartman on 24/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "UIAlertController+ASPDispatch.h"
#import "ASPFuture.h"
#import "ASPDispatchUIKitHelpers.h"

@implementation UIAlertController (ASPDispatch)
+ (ASPFuture *) asp_showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel otherButtons:(NSArray *)other
{
	return [ASPFuture inlineFuture:^(ASPPromise *p) {
		UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
		[vc addAction:[UIAlertAction actionWithTitle:cancel ? : other ? NSLocalizedString(@"Cancel", nil) : NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
			p.error = [[NSError alloc] initWithDomain:@"ASPDispatch" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"User canceled" }];
		}]];
		[other enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[vc addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				p.result = @(idx + 1);
			}]];
		}];
		[ASPDispatchCurrentViewController() presentViewController:vc animated:YES completion:nil];
	}];
}
@end