//
//  CTRESTfulCoreData.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "NSArray+CTRESTfulCoreData.h"
#import "NSDate+CTRESTfulCoreData.h"
#import "NSError+CTRESTfulCoreData.h"
#import "NSObject+CTRESTfulCoreData.h"
#import "NSString+CTRESTfulCoreData.h"
#import "NSURL+CTRESTfulCoreData.h"

#import "NSManagedObject+CTRESTfulCoreData.h"
#import "CTManagedObjectMappingModel.h"
#import "CTManagedObjectValidationModel.h"

#import "CTRESTfulCoreDataGlobal.h"
#import "CTRESTfulCoreDataBackgroundQueue.h"

/**
 Format string with which dates will be converted. Default is @"yyyy-MM-dd'T'HH:mm:ss'Z'".
 */
extern NSString *CTRESTfulCoreDataDateFormatString;

extern NSString *const CTRESTfulCoreDataRemoteOperationDidStartNotification;
extern NSString *const CTRESTfulCoreDataRemoteOperationDidFinishNotification;

static inline NSArray *CTRESTfulCoreDataManagedObjectIDCollector(NSArray *objects)
{
    return [objects CTArrayByCollectionObjectsWithCollector:^id(NSManagedObject *object, NSUInteger index, BOOL *stop) {
        return object.objectID;
    }];
}

static inline NSArray *CTRESTfulCoreDataManagedObjectCollector(NSArray *objectIDs, NSManagedObjectContext *context)
{
    return [objectIDs CTArrayByCollectionObjectsWithCollector:^id(NSManagedObjectID *objectID, NSUInteger index, BOOL *stop) {
        return [context objectWithID:objectID];
    }];
}
