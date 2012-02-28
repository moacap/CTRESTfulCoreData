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

/**
 Fetches an array of objects for this class and stores it in core data.
 */
+ (void)fetchObjectsFromURL:(NSURL *)URL
          completionHandler:(void(^)(NSArray *fetchedObjects, NSError *error))completionHandler;

/**
 Fetches objects from a URL for a given relationship.
 
 URL support substitution of object specific attributes:
 http://0.0.0.0:3000/api/object/:some_id/relationship
 where :some_id will be substituted with the content of the attribute from this self with someID or whatever mapping was specified.
 
 Supported relationships are 1-to-many and 1-to-1.
 */
- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler;

@end
