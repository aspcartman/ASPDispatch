//
// Created by ASPCartman on 23/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASPDynamicDelegate : NSObject
/*
 * Convenience method
 */
+ (instancetype) delegate:(void (^)(ASPDynamicDelegate *))block;

/*
 * The block may have no args or if it does it have a first-dummy id
 * argument which will be just nil
 */
- (void) addMethodForSelector:(SEL)sel withBlock:(id)block;
@end