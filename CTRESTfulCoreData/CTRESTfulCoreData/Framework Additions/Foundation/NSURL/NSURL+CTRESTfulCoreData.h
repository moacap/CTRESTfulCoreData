//
//  NSURL+CTRESTfulCoreData.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CTRESTfulCoreData)

/**
 Performs attribute substitution.
 */
- (NSURL *)URLBySubstitutingAttributesWithManagedObject:(NSManagedObject *)managedObject;

@end
