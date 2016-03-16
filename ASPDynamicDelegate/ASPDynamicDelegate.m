//
// Created by ASPCartman on 23/10/15.
// Copyright (c) 2015 ASPCartman. All rights reserved.
//

#import "ASPDynamicDelegate.h"
#import "objc/runtime.h"

/*
 * Enum and struct has been taken from https://github.com/llvm-mirror/clang/blob/52ed5ec631b0bbf5c714baa0cd83c33ebfe0c6aa/docs/Block-ABI-Apple.rst
 * and modified, taking in account https://github.com/llvm-mirror/clang/blob/52ed5ec631b0bbf5c714baa0cd83c33ebfe0c6aa/test/CodeGen/blockstret.c,
 * where it says there two structures actually, one with copy_helper, dispose_helper fields, and the other without. Union it is!
 *
 * Do not use those implementation anywhere except when you know what you're doing. sizeof() those different stuctures are not equal in the wild!
 * Here I ignore this fact for the simplicity sake.
 */
enum ASPBlockFlags
{
	BLOCK_HAS_COPY_DISPOSE = (1 << 25),
	BLOCK_HAS_SIGNATURE    = (1 << 30),
};

struct ASPBlockDescriptor
{
	__unused unsigned long int reserved;
	__unused unsigned long int size;
	union
	{
		struct
		{
			__unused void (*copy_helper)(void *dst, void *src);
			__unused void (*dispose_helper)(void *src);
			const char    *copy_dispose_signature;
		};

		const char *usual_signature;
	};
};

struct ASPBlock
{
	__unused void                *isa;
	int                          flags;
	__unused enum ASPBlockFlags  reserved;
	__unused void                (*invoke)(void *, ...);
	struct ASPBlockDescriptor    *descriptor;
	// Ignore everything below.
};

static const char *ASPGetBlockSignature(struct ASPBlock *block)
{
	NSCAssert((block->flags & BLOCK_HAS_SIGNATURE) == BLOCK_HAS_SIGNATURE, @"This block doesn't have a signature embedded. No go, sorry.");
	NSCAssert(block->descriptor != NULL, @"This block doesn't have a descriptor embedded. No go, sorry.");

	return block->flags & BLOCK_HAS_COPY_DISPOSE ? block->descriptor->copy_dispose_signature : block->descriptor->usual_signature;
}

@implementation ASPDynamicDelegate

+ (instancetype) alloc
{
	static uint classCounter = 0;
	if ([self class] == [ASPDynamicDelegate class])
	{
		Class newClass = objc_allocateClassPair([self class], [[NSString stringWithFormat:@"%@_%d_%d", [self class], classCounter, arc4random()] cStringUsingEncoding:NSUTF8StringEncoding], 0);
		objc_registerClassPair(newClass);
		id object = [newClass alloc];
		classCounter++;
		return object;
	}
	return [self allocWithZone:nil];
}

+ (instancetype) delegate:(void (^)(ASPDynamicDelegate *))block
{
	ASPDynamicDelegate *delegate = [self new];
	block(delegate);
	return delegate;
}

- (void) addMethodForSelector:(SEL)sel withBlock:(id)block
{
	IMP        newImp     = imp_implementationWithBlock(block);
	const char *signature = ASPGetBlockSignature((__bridge struct ASPBlock *) block);
	class_addMethod([self class], sel, newImp, signature);
}

- (void) dealloc
{
//	objc_disposeClassPair([self class]);
}
@end


