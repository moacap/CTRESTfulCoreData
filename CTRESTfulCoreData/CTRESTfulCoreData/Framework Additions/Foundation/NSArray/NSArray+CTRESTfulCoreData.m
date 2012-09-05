//
//  NSArray+CTRESTfulCoreData.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 04.09.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "NSArray+CTRESTfulCoreData.h"

@implementation NSArray (CTRESTfulCoreData)

- (NSArray *)CTArrayByCollectionObjectsWithCollector:(id(^)(id object, NSUInteger index, BOOL *stop))collector
{
    NSParameterAssert(collector);
    
    NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id object = collector(obj, idx, stop);
        
        if (object) {
            [finalArray addObject:object];
        }
    }];
    
    return finalArray;
}

@end
