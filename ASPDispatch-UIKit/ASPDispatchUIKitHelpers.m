//
// Created by ASPCartman on 24/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "ASPDispatchUIKitHelpers.h"

BOOL ASPDispatchOSVersionIsBelow(NSString *version)
{
	return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending);
}

UIViewController *ASPDispatchCurrentViewController()
{
	UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (topController.presentedViewController)
	{
		topController = topController.presentedViewController;
	}
	return topController;
}