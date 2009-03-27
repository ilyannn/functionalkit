#import "NSArray+FunctionalKit.h"
#import "FKMacros.h"

// TODO - Add stuff like these
//@interface NSArray (FK)
//- (NSArray *)zip:(NSArray *)other;
//@end
//
//@implementation NSArray (FK)
//- (NSArray *)zip:(NSArray *)other {
//	assert([other count] == [self count]);
//	NSMutableArray *r = [NSMutableArray arrayWithCapacity:[self count]];
//	for (int i = 0; i < [self count]; ++i) {
//		[r addObject:[FKP2 p2With_1:[self objectAtIndex:i] _2:[other objectAtIndex:i]]];
//	}
//	return [NSArray arrayWithArray:r];
//}
//@end

@interface FKLiftedFunction : FKFunction {
	id <FKFunction> wrappedF;
}

READ id <FKFunction> wrappedF;

- (FKLiftedFunction *)initWithF:(FKFunction *)wrappedF;

@end

@implementation FKLiftedFunction

@synthesize wrappedF;

- (FKLiftedFunction *)initWithF:(FKFunction *)inWrappedF {
	if ((self = [super init])) {
		wrappedF = [inWrappedF retain];
	}
	return self;
}

// TODO This is just a map. Fix it.
- (id):(id)arg {
	assert([arg isKindOfClass:[NSArray class]]);
	NSArray *argArray = arg;
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[arg count]];
	for (id obj in argArray) {
		[arr addObject:[wrappedF :obj]];
	}
	return arr;
}

#pragma mark NSObject methods.
- (void) dealloc {
    [wrappedF release];
    [super dealloc];
}

- (BOOL)isEqual:(id)object {
    return object == nil || ![[object class] isEqual:[self class]] ? NO : [wrappedF isEqual:((FKLiftedFunction *) object).wrappedF];
}

- (NSUInteger)hash {
    return 42;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%s wrappedF: %@>", class_getName([self class]), wrappedF];
}

@end

@implementation NSArray (FunctionalKitExtensions)

- (id)head {
    if ([self count] == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot get the head of an empty array" userInfo:EMPTY_DICT];
    } else {
        return [self objectAtIndex:0];
    }
}

- (NSArray *)tail {
    if ([self count] == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot get the tail of an empty array" userInfo:EMPTY_DICT];
    } else {
        return [self subarrayWithRange:NSMakeRange(1, [self count] - 1)];
    }
}

- (BOOL)all:(id <FKFunction>)f {
	for (id item in self) {
		if (![f :item]) {
			return NO;
		}
	}
	return YES;    
}

- (NSArray *)filter:(id <FKFunction>)f {
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[self count]];
	for (id item in self) {
		if ([f :item]) {
            [filtered addObject:item];
		}
	}
    return filtered;
}

- (NSArray *)group:(id <FKFunction>)f {
    
	NSMutableArray *grouped = [NSMutableArray array];
	for (id item in self) {
		if ([f :item]) {
            
            [grouped addObject:item];
		}
	}    
    
    return grouped;
}

- (NSArray *)map:(id <FKFunction>)f {
	NSMutableArray *r = [NSMutableArray arrayWithCapacity:[self count]];
	for (id item in self) {
		[r addObject:[f :item]];
	}
	return [NSArray arrayWithArray:r];
}

- (void)foreach:(id <FKFunction>)f {
	for (id o in self) {
		[f :o];
	}
}

+ (id <FKFunction>)liftFunction:(id <FKFunction>)f {
	return [[[FKLiftedFunction alloc] initWithF:f] autorelease];
}

@end
