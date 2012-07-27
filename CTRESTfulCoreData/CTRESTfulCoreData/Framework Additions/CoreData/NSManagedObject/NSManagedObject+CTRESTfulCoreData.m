//
//  NSManagedObject+CTRESTfulCoreData.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"
#import "NSArray+CTRESTfulCoreData.h"

NSString *const CTRESTfulCoreDataMappingModelKey = @"CTRESTfulCoreDataMappingModelKey";
NSString *const CTRESTfulCoreDataValidationModelKey = @"CTRESTfulCoreDataValidationModelKey";
NSString *const CTRESTfulCoreDataBackgroundQueueNameKey = @"CTRESTfulCoreDataBackgroundQueueNameKey";



@implementation NSManagedObject (CTRESTfulCoreDataQueryInterface)

+ (void)fetchObjectsFromURL:(NSURL *)URL
          completionHandler:(void(^)(NSArray *fetchedObjects, NSError *error))completionHandler
{
    [self fetchObjectsFromURL:URL
       deleteEveryOtherObject:YES
            completionHandler:completionHandler];
}

+ (void)fetchObjectsFromURL:(NSURL *)URL
     deleteEveryOtherObject:(BOOL)deleteEveryOtherObject
          completionHandler:(void (^)(NSArray *, NSError *))completionHandlerZZZ
{
    // send request to given URL
    [self.backgroundQueue getRequestToURL:URL
                        completionHandler:^(id JSONObject, NSError *error)
     {
         NSMutableArray *fetchedObjectIDs = [NSMutableArray array];
         
         if (error != nil) {
             // check for error
             completionHandlerZZZ(nil, error);
             return;
         } else {
             // success for now
             NSManagedObjectContext *backgroundContext = [self backgroundThreadManagedObjectContext];
             
             [backgroundContext performBlock:^{
                 
                 void(^successBlock)(NSArray *objectIDs) = ^(NSArray *objectIDs) {
                     dispatch_async(dispatch_get_main_queue(), ^(void) {
                         NSManagedObjectContext *mainThreadContext = [self mainThreadManagedObjectContext];
                         
                         [mainThreadContext performBlock:^{
                             NSArray *finalObjectArray = [objectIDs CTArrayByCollectionObjectsWithCollector:^id(NSManagedObjectID *objectID, NSUInteger index, BOOL *stop) {
                                 return [mainThreadContext objectWithID:objectID];
                             }];
                             
                             completionHandlerZZZ(finalObjectArray, nil);
                         }];
                     });
                 };
                 
                 void(^failureBlock)(NSError *error) = ^(NSError *error) {
                     dispatch_async(dispatch_get_main_queue(), ^(void) {
                         completionHandlerZZZ(nil, error);
                     });
                 };
                 
                 NSArray *(^objectIDCollector)(NSArray *objects) = ^(NSArray *objects) {
                     return [objects CTArrayByCollectionObjectsWithCollector:^id(NSManagedObject *object, NSUInteger index, BOOL *stop) {
                         return object.objectID;
                     }];
                 };
                 
                 NSMutableArray *updatedObjects = [NSMutableArray array];
                 
                 if ([JSONObject isKindOfClass:NSArray.class]) {
                     // convert all JSON objects into NSManagedObjects
                     for (NSDictionary *rawDictionary in JSONObject) {
                         if (![rawDictionary isKindOfClass:NSDictionary.class]) {
                             failureBlock([NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                             return;
                         }
                         
                         id object = [self updatedObjectWithRawJSONDictionary:rawDictionary inManagedObjectContext:backgroundContext];
                         if (object) {
                             [updatedObjects addObject:object];
                         } else {
                             failureBlock([NSError CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:JSONObject fromURL:URL]);
                             return;
                         }
                         
                         NSNumber *JSONObjectID = [rawDictionary objectForKey:@"id"];
                         if (JSONObjectID) {
                             [fetchedObjectIDs addObject:JSONObjectID];
                         }
                     }
                 } else if ([JSONObject isKindOfClass:NSDictionary.class]) {
                     id object = [self updatedObjectWithRawJSONDictionary:JSONObject inManagedObjectContext:backgroundContext];
                     
                     if (object) {
                         [updatedObjects addObject:object];
                     } else {
                         failureBlock([NSError CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:JSONObject fromURL:URL]);
                         return;
                     }
                 } else {
                     // object is not supported
                     failureBlock([NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                     return;
                 }
                 
                 if (deleteEveryOtherObject) {
                     // now delete every object not returned from the API
                     [self deleteObjectsWithoutRemoteIDs:fetchedObjectIDs inManagedObjectContext:backgroundContext];
                 }
                 
                 [backgroundContext save:NULL];
                 
                 successBlock(objectIDCollector(updatedObjects));
             }];
         }
     }];
}

- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler
{
    [self fetchObjectsForRelationship:relationship
                              fromURL:URL
               deleteEveryOtherObject:YES
                    completionHandler:completionHandler];
}

- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
             deleteEveryOtherObject:(BOOL)deleteEveryOtherObject
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler
{
    // send request to given URL
    [self.class.backgroundQueue getRequestToURL:[URL URLBySubstitutingAttributesWithManagedObject:self]
                              completionHandler:^(id JSONObject, NSError *error)
     {
         if (error) {
             // check for error
             completionHandler(nil, error);
             return;
         } else {
             // success for now
             NSManagedObjectID *objectID = self.objectID;
             NSManagedObjectContext *backgroundContext = [self.class backgroundThreadManagedObjectContext];
             
             [backgroundContext performBlock:^{
                 NSManagedObject *backgroundSelf = [backgroundContext objectWithID:objectID];
                 NSError *error = nil;
                 
                 NSArray *updatedObjects = [backgroundSelf updateObjectsForRelationship:relationship
                                                                         withJSONObject:JSONObject
                                                                                fromURL:URL
                                                                 deleteEveryOtherObject:deleteEveryOtherObject
                                                                                  error:&error];
                 
                 NSArray *objectIDs = CTRESTfulCoreDataManagedObjectIDCollector(updatedObjects);
                 
                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                     NSManagedObjectContext *mainThreadContext = [self.class mainThreadManagedObjectContext];
                     [mainThreadContext performBlock:^{
                         NSArray *objects = CTRESTfulCoreDataManagedObjectCollector(objectIDs, mainThreadContext);
                         completionHandler(objects, error);
                     }];
                 });
             }];
         }
     }];
}

- (void)postToURL:(NSURL *)URL completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler
{
    NSString *JSONObjectPrefix = [self.class JSONObjectPrefix];
    NSDictionary *rawJSONDictionary = self.rawJSONDictionary;
    
    if (JSONObjectPrefix) {
        rawJSONDictionary = [NSDictionary dictionaryWithObject:rawJSONDictionary forKey:JSONObjectPrefix];
    }
    
    [self.class.backgroundQueue postJSONObject:rawJSONDictionary
                                         toURL:[URL URLBySubstitutingAttributesWithManagedObject:self]
                             completionHandler:^(id JSONObject, NSError *error) {
                                 if (error) {
                                     completionHandler(self, error);
                                 } else {
                                     [self updateWithRawJSONDictionary:JSONObject];
                                     completionHandler(self, nil);
                                 }
                             }];
}

- (void)putToURL:(NSURL *)URL completionHandler:(void (^)(id JSONObject, NSError *error))completionHandler
{
    NSString *JSONObjectPrefix = [self.class JSONObjectPrefix];
    NSDictionary *rawJSONDictionary = self.rawJSONDictionary;
    
    if (JSONObjectPrefix) {
        rawJSONDictionary = [NSDictionary dictionaryWithObject:rawJSONDictionary forKey:JSONObjectPrefix];
    }
    
    [self.class.backgroundQueue putJSONObject:rawJSONDictionary
                                        toURL:[URL URLBySubstitutingAttributesWithManagedObject:self]
                            completionHandler:^(id JSONObject, NSError *error) {
                                if (error) {
                                    completionHandler(self, error);
                                } else {
                                    [self updateWithRawJSONDictionary:JSONObject];
                                    completionHandler(self, nil);
                                }
                            }];
}

- (void)deleteToURL:(NSURL *)URL completionHandler:(void (^)(NSError *error))completionHandler
{
    [self.class.backgroundQueue deleteRequestToURL:[URL URLBySubstitutingAttributesWithManagedObject:self] completionHandler:^(NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
        } else {
            [self.class.managedObjectContext deleteObject:self];
            if (completionHandler) {
                completionHandler(nil);
            }
        }
    }];
}

@end



@implementation NSManagedObject (CTRESTfulCoreData)

+ (NSArray *)attributeNames
{
    NSManagedObjectContext *context = [self mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self)
                                                         inManagedObjectContext:context];
    
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    
    NSArray *allAttributes = entityDescription.attributesByName.allKeys;
    NSMutableArray *registeredAttributes = [NSMutableArray arrayWithCapacity:allAttributes.count];
    
    [allAttributes enumerateObjectsUsingBlock:^(NSString *attributeName, NSUInteger idx, BOOL *stop) {
        if ([mappingModel isAttributeNameRegistered:attributeName]) {
            [registeredAttributes addObject:attributeName];
        }
    }];
    
    return registeredAttributes;
}

+ (NSRelationshipDescription *)relationshipDescriptionNamed:(NSString *)relationshipName
{
    NSManagedObjectContext *context = [self mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self)
                                                         inManagedObjectContext:context];
    return [entityDescription.relationshipsByName objectForKey:relationshipName];
}

+ (NSManagedObjectContext *)mainThreadManagedObjectContext
{
    [NSException raise:NSInternalInconsistencyException format:@"%@ does not recognize selector %@", self, NSStringFromSelector(_cmd)];
    return nil;
}

+ (NSManagedObjectContext *)backgroundThreadManagedObjectContext
{
    [NSException raise:NSInternalInconsistencyException format:@"%@ does not recognize selector %@", self, NSStringFromSelector(_cmd)];
    return nil;
}

+ (id<CTRESTfulCoreDataBackgroundQueue>)backgroundQueue
{
    NSString *className = objc_getAssociatedObject(self, &CTRESTfulCoreDataBackgroundQueueNameKey);
    
    if (!className) {
        NSString *prefix = [self classPrefix];
        className = [NSString stringWithFormat:@"%@BackgroundQueue", prefix];
        objc_setAssociatedObject(self, &CTRESTfulCoreDataBackgroundQueueNameKey, className, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    Class backgroundQueueClass = NSClassFromString(className);
    NSAssert(backgroundQueueClass != nil, @"There is no class named %@. Create a class with this name or overwrite +[NSManagedObject backgroundQueue].", className);
    NSAssert(class_conformsToProtocol(backgroundQueueClass, @protocol(CTRESTfulCoreDataBackgroundQueue)), @"Class %@ does not conform to CTRESTfulCoreDataBackgroundQueue protocol", backgroundQueueClass);
    
    return [backgroundQueueClass sharedQueue];
}

+ (CTManagedObjectMappingModel *)mappingModel
{
    CTManagedObjectMappingModel *mappingModel = objc_getAssociatedObject(self, &CTRESTfulCoreDataMappingModelKey);
    
    if (!mappingModel) {
        mappingModel = [[CTManagedObjectMappingModel alloc] init];
        objc_setAssociatedObject(self, &CTRESTfulCoreDataMappingModelKey, mappingModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        Class superclass = class_getSuperclass(self);
        if ([superclass isSubclassOfClass:NSManagedObject.class]) {
            [mappingModel mergeWithMappingModel:[superclass mappingModel]];
        }
    }
    
    return mappingModel;
}

+ (CTManagedObjectValidationModel *)validationModel
{
    CTManagedObjectValidationModel *validationModel = objc_getAssociatedObject(self, &CTRESTfulCoreDataValidationModelKey);
    
    if (!validationModel) {
        validationModel = [[CTManagedObjectValidationModel alloc] initWithManagedObjectClassName:NSStringFromClass(self)];
        
        [validationModel setValueTransformationHandler:^id(id object, NSString *managedObjectAttributeName) {
            CTManagedObjectMappingModel *mappingModel = self.mappingModel;
            
            CTCustomTransformableValueTransformationHandler valueTransformer = [mappingModel valueTransformerForManagedObjectAttributeName:managedObjectAttributeName];
            if (valueTransformer) {
                return valueTransformer(object, managedObjectAttributeName);
            }
            
            return nil;
        }];
        
        [validationModel setInverseValueTransformationHandler:^id(id object, NSString *managedObjectAttributeName) {
            CTManagedObjectMappingModel *mappingModel = self.mappingModel;
            
            CTCustomTransformableValueTransformationHandler valueTransformer = [mappingModel inverseValueTransformerForManagedObjectAttributeName:managedObjectAttributeName];
            if (valueTransformer) {
                return valueTransformer(object, managedObjectAttributeName);
            }
            
            return nil;
        }];
        
        objc_setAssociatedObject(self, &CTRESTfulCoreDataValidationModelKey, validationModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return validationModel;
}

+ (void)registerAttributeName:(NSString *)attributeName forJSONObjectKeyPath:(NSString *)JSONObjectKeyPath
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    
    [mappingModel registerAttribute:attributeName forJSONObjectKeyPath:JSONObjectKeyPath];
}

+ (void)unregisterAttributeName:(NSString *)attributeName
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    
    [mappingModel unregisterAttributeName:attributeName];
}

+ (NSString *)JSONObjectPrefix
{
    return nil;
}

+ (void)registerSubclass:(Class)subclass forManagedObjectAttributeName:(NSString *)managedObjectAttributeName withValue:(id)value
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    
    [mappingModel registerSubclass:subclass forManagedObjectAttributeName:managedObjectAttributeName withValue:value];
}

+ (void)registerValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)valueTransformerHandler
          forManagedObjectAttributeName:(NSString *)managedObjectAttributeName
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    
    [mappingModel registerValueTransformerHandler:valueTransformerHandler
                    forManagedObjectAttributeName:managedObjectAttributeName];
}

+ (void)registerInverseValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)inservseValueTransformerHandler
                 forManagedObjectAttributeName:(NSString *)managedObjectAttributeName
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    
    [mappingModel registerInverseValueTransformerHandler:inservseValueTransformerHandler
                           forManagedObjectAttributeName:managedObjectAttributeName];
}

+ (id)updatedObjectWithRawJSONDictionary:(NSDictionary *)rawDictionary
                  inManagedObjectContext:(NSManagedObjectContext *)context
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    CTManagedObjectValidationModel *validationModel = [self validationModel];
    
    if (![rawDictionary isKindOfClass:NSDictionary.class]) {
        DLog(@"WARNING: JSON Object is not a NSDictionary (%@)", rawDictionary);
        return nil;
    }
    
    Class modelClass = [mappingModel subclassForRawJSONDictionary:rawDictionary];
    if (!modelClass) {
        modelClass = self;
    }
    NSString *modelClassName = NSStringFromClass(modelClass);
    NSString *idKey = [mappingModel keyForManagedObjectFromJSONObjectKeyPath:@"id"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:modelClassName];
    id JSONObjectID = [rawDictionary objectForKey:@"id"];
    NSNumber *idNumber = [validationModel managedObjectObjectFromJSONObjectObject:JSONObjectID
                                                        forManagedObjectAttribute:idKey];
    
    if (!idNumber) {
        DLog(@"WARNING: JSON Object did not have an id (%@)", rawDictionary);
        return nil;
    }
    
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", idKey, idNumber];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    NSAssert(error == nil, @"error while fetching: %@", error);
    
    NSManagedObject *object = nil;
    if (objects.count > 0) {
        object = [objects objectAtIndex:0];
    } else {
        object = [NSEntityDescription insertNewObjectForEntityForName:modelClassName
                                               inManagedObjectContext:context];
    }
    
    [object updateWithRawJSONDictionary:rawDictionary];
    
    return object;
}

- (void)updateWithRawJSONDictionary:(NSDictionary *)rawDictionary
{
    NSArray *attributes = [self.class attributeNames];
    CTManagedObjectValidationModel *validationModel = [self.class validationModel];
    CTManagedObjectMappingModel *mappingModel = self.class.mappingModel;
    
    for (NSString *attributeName in attributes) {
        NSString *JSONObjectKeyPath = [mappingModel keyForJSONObjectFromManagedObjectAttribute:attributeName];
        id rawJSONObject = [rawDictionary valueForKeyPath:JSONObjectKeyPath];
        
        id myValue = [validationModel managedObjectObjectFromJSONObjectObject:rawJSONObject
                                                    forManagedObjectAttribute:attributeName];
        
        if (myValue) {
            [self setValue:myValue forKey:attributeName];
        }
    }
}

- (NSDictionary *)rawJSONDictionary
{
    CTManagedObjectMappingModel *mappingModel = self.class.mappingModel;
    CTManagedObjectValidationModel *validationModel = [self.class validationModel];
    
    NSMutableDictionary *rawJSONDictionary = [NSMutableDictionary dictionary];
    
    [self.class.attributeNames enumerateObjectsUsingBlock:^(NSString *attributeName, NSUInteger idx, BOOL *stop) {
        id value = [self valueForKey:attributeName];
        
        if (value) {
            NSString *JSONObjectKey = [mappingModel keyForJSONObjectFromManagedObjectAttribute:attributeName];
            id JSONObjectValue = [validationModel JSONObjectObjectFromManagedObjectObject:value
                                                                forManagedObjectAttribute:attributeName];
            
            [rawJSONDictionary setObject:JSONObjectValue forKey:JSONObjectKey];
        }
    }];
    
    return rawJSONDictionary;
}

+ (id)objectWithRemoteID:(NSNumber *)ID inManagedObjectContext:(NSManagedObjectContext *)context
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    NSString *idKey = [mappingModel keyForManagedObjectFromJSONObjectKeyPath:@"id"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", idKey, ID];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    NSAssert(error == nil, @"error while fetching: %@", error);
    
    if (objects.count > 0) {
        return [objects objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray *)objectsFromRelationship:(NSString *)relationship sortedByAttribute:(NSString *)attribute
{
    return [self objectsFromRelationship:relationship sortedByAttribute:attribute ascending:YES];
}

- (NSArray *)objectsFromRelationship:(NSString *)relationship sortedByAttribute:(NSString *)attribute ascending:(BOOL)ascending
{
    NSRelationshipDescription *relationshipDescription = [self.class relationshipDescriptionNamed:relationship];
    NSAssert(relationshipDescription != nil, @"no relationship with name %@ found", relationship);
    
    NSRelationshipDescription *inverseRelationshipDescription = relationshipDescription.inverseRelationship;
    NSAssert(inverseRelationshipDescription != nil, @"invers relationship not found for relationship %@", relationship);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:relationshipDescription.destinationEntity.managedObjectClassName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", inverseRelationshipDescription.name, self];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:attribute ascending:ascending]];
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSAssert(error == nil, @"error while fetching: %@", error);
    
    return objects;
}

+ (void)deleteObjectsWithoutRemoteIDs:(NSArray *)remoteIDs inManagedObjectContext:(NSManagedObjectContext *)context
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    NSString *idKey = [mappingModel keyForManagedObjectFromJSONObjectKeyPath:@"id"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
    request.predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", idKey, remoteIDs];
    
    NSError *error = nil;
    NSArray *objectsToBeDeleted = [context executeFetchRequest:request error:&error];
    NSAssert(error == nil, @"error while fetching: %@", error);
    
    for (id object in objectsToBeDeleted) {
        [context deleteObject:object];
    }
}

- (NSArray *)updateObjectsForRelationship:(NSString *)relationship
                           withJSONObject:(id)JSONObject
                                  fromURL:(NSURL *)URL
                   deleteEveryOtherObject:(BOOL)deleteEveryOtherObject
                                    error:(NSError *__autoreleasing *)error
{
    NSMutableArray *updatedObjects = [NSMutableArray array];
    
    // get relationship description, name of destination entity and the name of the invers relation.
    NSRelationshipDescription *relationshipDescription = [self.class relationshipDescriptionNamed:relationship];
    NSAssert(relationshipDescription != nil, @"There is no relationship %@ for %@", relationship, self.class);
    
    NSString *destinationClassName = relationshipDescription.destinationEntity.managedObjectClassName;
    NSAssert(destinationClassName != nil, @"no managedObjectClassName specified for destinationEntity %@", relationshipDescription.destinationEntity);
    NSString *inverseRelationshipName = relationshipDescription.inverseRelationship.name;
    NSAssert(inverseRelationshipName != nil, @"no inverseRelationshipName specified for relationshipDescription %@", relationshipDescription);
    NSParameterAssert(error);
    
    // update attributes based in relationship type
    if (relationshipDescription.isToMany) {
        // is a 1-to-many relation
        if (![JSONObject isKindOfClass:NSArray.class]) {
            // make sure JSONObject has correct class
            *error = [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL];
            return nil;
        }
        NSArray *JSONObjectsArray = JSONObject;
        
        // enumerate raw JSON objects and update destination entity with these.
        for (NSDictionary *rawDictionary in JSONObjectsArray) {
            if (![rawDictionary isKindOfClass:NSDictionary.class]) {
                // make sure JSONObject has correct class
                *error = [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL];
                return nil;
            }
            
            id object = [NSClassFromString(destinationClassName) updatedObjectWithRawJSONDictionary:rawDictionary inManagedObjectContext:self.managedObjectContext];
            [object setValue:self forKey:inverseRelationshipName];
            
            if (object) {
                [updatedObjects addObject:object];
            } else {
                *error = [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL];
                return nil;
            }
        }
    } else {
        if (![JSONObject isKindOfClass:NSDictionary.class]) {
            // make sure JSONObject has correct class
            *error = [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL];
            return nil;
        }
        
        // update destination entity with JSON object.
        id object = [NSClassFromString(destinationClassName) updatedObjectWithRawJSONDictionary:JSONObject inManagedObjectContext:self.managedObjectContext];
        [self setValue:object forKey:relationship];
        
        if (object) {
            [updatedObjects addObject:object];
        } else {
            *error = [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL];
            return nil;
        }
    }
    
    if (deleteEveryOtherObject) {
        NSMutableSet *deletionSet = [[self valueForKey:relationship] mutableCopy];
        for (id object in updatedObjects) {
            [deletionSet removeObject:object];
        }
        
        for (id object in deletionSet) {
            [self.managedObjectContext deleteObject:object];
        }
    }
    
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        *error = saveError;
    }
    
    return updatedObjects;
}

@end
