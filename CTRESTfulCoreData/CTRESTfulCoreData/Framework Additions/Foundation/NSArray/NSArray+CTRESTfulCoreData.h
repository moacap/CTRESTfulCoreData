//
//  NSArray+CTRESTfulCoreData.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 04.09.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

@interface NSArray (CTRESTfulCoreData)

- (NSArray *)CTArrayByCollectionObjectsWithCollector:(id(^)(id object, NSUInteger index, BOOL *stop))collector;

@end
