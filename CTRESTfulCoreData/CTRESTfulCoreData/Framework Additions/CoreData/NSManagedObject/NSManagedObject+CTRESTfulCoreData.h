//
//  NSManagedObject+CTRESTfulCoreData.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

@class CTManagedObjectMappingModel, CTManagedObjectValidationModel;

extern NSString *const CTRESTfulCoreDataMappingModelKey;
extern NSString *const CTRESTfulCoreDataValidationModelKey;



@interface NSManagedObject (CTRESTfulCoreData)

/**
 Returns a unique instance for each subclass.
 */
+ (CTManagedObjectMappingModel *)mappingModel;

/**
 Returns a unique instance for each subclass.
 */
+ (CTManagedObjectValidationModel *)validationModelForManagedObjectContext:(NSManagedObjectContext *)context;

/**
 @return NSArray with a NSString for each attribute belonging to this entity.
 */
+ (NSArray *)attributeNamesInManagedObjectContext:(NSManagedObjectContext *)context;

/**
 Registers a mapping between a CoreData attribute and a corresponding key path of a JSON object, with which this object will be updated.
 The default lookup is attributeName.
 
 @warning: Call in +[NSManagedObjectSubclass initialize].
 */
+ (void)registerAttributeName:(NSString *)attributeName
         forJSONObjectKeyPath:(NSString *)JSONObjectKeyPath;

/**
 Searches for an existing entity with id given in dictionary and updates attributes or created new one with given attributes.
 */
+ (id)updatedObjectWithRawJSONDictionary:(NSDictionary *)dictionary
                  inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 Updates the actual instance with the given JSON dictionary;
 */
- (void)updateWithRawJSONDictionary:(NSDictionary *)dictionary;

@end
