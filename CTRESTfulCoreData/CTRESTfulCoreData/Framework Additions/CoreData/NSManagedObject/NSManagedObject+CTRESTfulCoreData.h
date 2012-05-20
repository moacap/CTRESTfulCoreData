//
//  NSManagedObject+CTRESTfulCoreData.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreDataBackgroundQueue.h"
#import "CTRESTfulCoreDataGlobal.h"

@class CTManagedObjectMappingModel, CTManagedObjectValidationModel;

extern NSString *const CTRESTfulCoreDataMappingModelKey;
extern NSString *const CTRESTfulCoreDataValidationModelKey;
extern NSString *const CTRESTfulCoreDataBackgroundQueueNameKey;



@interface NSManagedObject (CTRESTfulCoreDataQueryInterface)

/**
 Calls +[NSManagedObject fetchObjectsFromURL:URL deleteEveryOtherObject:YES completionHandler:completionHandler].
 */
+ (void)fetchObjectsFromURL:(NSURL *)URL
          completionHandler:(void(^)(NSArray *fetchedObjects, NSError *error))completionHandler;

/**
 Fetches an array of objects or a single object for this class and stores it in core data. URL is expected to return an NSArray with NSDictionaries which contain the JSON object.
 
 @param deleteEveryOtherObject: If YES, each object that is not returned by the API will be deleted from the data base
 */
+ (void)fetchObjectsFromURL:(NSURL *)URL
     deleteEveryOtherObject:(BOOL)deleteEveryOtherObject
          completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler;

/**
 Calls -[NSManagedObject fetchObjectsForRelationship:relationship fromURL:URL deleteEveryOtherObject:YES completionHandler:completionHandler].
 */
- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler;

/**
 Fetches objects from a URL for a given relationship.
 
 URL support substitution of object specific attributes:
 http://0.0.0.0:3000/api/object/:some_id/relationship
 where :some_id will be substituted with the content of the attribute from this self with someID or whatever mapping was specified.
 
 Supported relationships are 1-to-many and 1-to-1.
 */
- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
             deleteEveryOtherObject:(BOOL)deleteEveryOtherObject
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler;

- (void)postToURL:(NSURL *)URL completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler;

@end



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
 @warning: You need to overwrite this method and return a threadsafe NSManagedObjectContext here.
 */
+ (NSManagedObjectContext *)managedObjectContext;

/**
 @return NSRelationshipDescription whichs name is relationshipName.
 */
+ (NSRelationshipDescription *)relationshipDescriptionNamed:(NSString *)relationshipName;

/**
 @return NSArray with a NSString for each attribute belonging to this entity.
 */
+ (NSArray *)attributeNames;

/**
 By default, this methods looks for a class which name starts with this classes prefix and end with BackgoundQueue.
 
 TTEntity1 will look for a background queue TTBackgroundQueue. Overwrite for custom behaviour.
 */
+ (id<CTRESTfulCoreDataBackgroundQueue>)backgroundQueue;

/**
 Registers a mapping between a CoreData attribute and a corresponding key path of a JSON object, with which this object will be updated.
 The default lookup is attributeName.
 
 @warning: Call in +[NSManagedObjectSubclass initialize].
 */
+ (void)registerAttributeName:(NSString *)attributeName
         forJSONObjectKeyPath:(NSString *)JSONObjectKeyPath;

/**
 Excludes attribute name from JSON object mapping an causes attributeName to not be set in updateWithRawJSONDictionary:.
 */
+ (void)unregisterAttributeName:(NSString *)attributeName;

/**
 POSTing objects will will be done by this prefix. If JSONObjectPrefix would be `registration` and the rawJSONObject would be { id: 5 } then CTRESTfulCoreData would POST { 'registration' : {id: 5} }, if JSONObjectPrefix is nil, CTRESTfulCoreData would simply POST rawJSONObject.
 */
+ (NSString *)JSONObjectPrefix;

/**
 Registers a custom subclass for a value of an attribute.
 */
+ (void)registerSubclass:(Class)subclass forManagedObjectAttributeName:(NSString *)managedObjectAttributeName withValue:(id)value;

/**
 Registers a custom value transformer handler for a managed object attribute name.
 */
+ (void)registerValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)valueTransformerHandler
          forManagedObjectAttributeName:(NSString *)managedObjectAttributeName;

/**
 Registers a custom inverse value transformer handler for a managed object attribute name.
 */
+ (void)registerInverseValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)inservseValueTransformerHandler
                 forManagedObjectAttributeName:(NSString *)managedObjectAttributeName;

/**
 Searches for an existing entity with id given in dictionary and updates attributes or created new one with given attributes.
 */
+ (id)updatedObjectWithRawJSONDictionary:(NSDictionary *)dictionary;

/**
 Updates the actual instance with the given JSON dictionary;
 */
- (void)updateWithRawJSONDictionary:(NSDictionary *)dictionary;

/**
 converts self into a JSON object.
 */
@property (nonatomic, readonly) NSDictionary *rawJSONDictionary;

/**
 @return Fetches an object of this class from database with a given it of a remote object.
 */
+ (id)objectWithRemoteID:(NSNumber *)ID;

/**
 @return [self objectsFromRelationship:relationship sortedByAttribute:attribute ascending:YES].
 */
- (NSArray *)objectsFromRelationship:(NSString *)relationship sortedByAttribute:(NSString *)attribute;

/**
 @return Sorted array of a given relationship by a given attribute ascending.
 */
- (NSArray *)objectsFromRelationship:(NSString *)relationship sortedByAttribute:(NSString *)attribute ascending:(BOOL)ascending;

/**
 Deletes a set of objects with given remote IDs.
 */
+ (void)deleteObjectsWithoutRemoteIDs:(NSArray *)remoteIDs;

/**
 Updates objects of relationship with objects from a JSON object.
 @return The updated objects.
 */
- (NSArray *)updateObjectsForRelationship:(NSString *)relationship
                           withJSONObject:(id)JSONObject
                                  fromURL:(NSURL *)URL
                   deleteEveryOtherObject:(BOOL)deleteEveryOtherObject
                                    error:(NSError *__autoreleasing *)error;

@end
