//
//  NSArray+VKUtil.m
//
//  Created by vick on 2021/3/9.
//

#import "NSArray+VKUtil.h"

@implementation NSArray (VKUtil)

- (NSArray *)vk_filter:(NSString *)format, ... {
    NSCParameterAssert(format != nil);
    va_list args;
    va_start(args, format);
    NSArray *array = [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
    va_end(args);
    return array;
}

- (NSArray *)filterBlock:(BOOL (^)(id))block {
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return block(evaluatedObject);
    }]];
}

- (NSArray *)reverse {
    return [[self reverseObjectEnumerator] allObjects];
}

- (NSArray *)unique {
    return [NSOrderedSet orderedSetWithArray:self].array;
}

- (NSArray *)sliceBy:(NSInteger)count {
    if (self.count < count) {
        return @[];
    }
    NSInteger segment = self.count / count;
    NSMutableArray *results = [NSMutableArray array];
    for (NSInteger i=0; i<segment; i++) {
        NSArray *subArray= [self subarrayWithRange:NSMakeRange(i*count, count)];
        [results addObject:subArray];
    }
    return results;
}

- (NSArray *)sliceTo:(NSInteger)count {
    NSInteger segment = self.count / count;
    segment = segment <= 0 ? 1 : segment;
    NSMutableArray *results = [NSMutableArray array];
    for (NSInteger i=0; i<count; i++) {
        NSInteger start = i * segment;
        if ((start + segment) <= self.count) {
            NSArray *subArray= [self subarrayWithRange:NSMakeRange(start, segment)];
            [results addObject:subArray];
        }
    }
    return results;
}

- (NSArray *)intersectSet:(NSArray *)array {
    NSMutableSet *selfSet = [NSMutableSet setWithArray:self];
    NSMutableSet *arraySet = [NSMutableSet setWithArray:array];
    [selfSet intersectSet:arraySet];
    return selfSet.allObjects;
}

- (NSArray *)minusSet:(NSArray *)array {
    NSMutableSet *selfSet = [NSMutableSet setWithArray:self];
    NSMutableSet *arraySet = [NSMutableSet setWithArray:array];
    [selfSet minusSet:arraySet];
    return selfSet.allObjects;
}

- (NSArray *)unionSet:(NSArray *)array {
    NSMutableSet *selfSet = [NSMutableSet setWithArray:self];
    NSMutableSet *arraySet = [NSMutableSet setWithArray:array];
    [selfSet unionSet:arraySet];
    return selfSet.allObjects;
}

- (NSArray *)sortedAscByKey:(NSString *)key {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    return [self sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray *)sortedDesByKey:(NSString *)key {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:NO];
    return [self sortedArrayUsingDescriptors:@[sort]];
}

- (id)safeObjectWithIndex:(NSUInteger)index {
    if (index < self.count) {
        return self[index];
    } else {
        return nil;
    }
}

@end
