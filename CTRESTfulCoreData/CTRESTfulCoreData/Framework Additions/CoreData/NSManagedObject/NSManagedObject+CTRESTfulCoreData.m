//
//  NSManagedObject+CTRESTfulCoreData.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"

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
          completionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    // send request to given URL
    [self.backgroundQueue getRequestToURL:URL
                        completionHandler:^(id JSONObject, NSError *error)
     {
         NSMutableArray *fetchedObjectIDs = [NSMutableArray array];
         
         if (error != nil) {
             // check for error
             completionHandler(nil, error);
             return;
         } else {
             // success for now
             
             if ([JSONObject isKindOfClass:NSArray.class]) {
                 NSArray *JSONObjectArray = JSONObject;
                 NSMutableArray *updatedObjects = [NSMutableArray arrayWithCapacity:JSONObjectArray.count];
                 
                 // convert all JSON objects into NSManagedObjects
                 for (NSDictionary *rawDictionary in JSONObject) {
                     if (![rawDictionary isKindOfClass:NSDictionary.class]) {
                         completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                         return;
                     }
                     
                     id object = [self updatedObjectWithRawJSONDictionary:rawDictionary];
                     if (object) {
                         [updatedObjects addObject:object];
                     } else {
                         completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:JSONObject fromURL:URL]);
                         return;
                     }
                     
                     NSNumber *JSONObjectID = [rawDictionary objectForKey:@"id"];
                     if (JSONObjectID) {
                         [fetchedObjectIDs addObject:JSONObjectID];
                     }
                 }
                 
                 completionHandler(updatedObjects, nil);
             } else if ([JSONObject isKindOfClass:NSDictionary.class]) {
                 id object = [self updatedObjectWithRawJSONDictionary:JSONObject];
                 
                 if (object) {
                     completionHandler([NSArray arrayWithObject:object], nil);
                 } else {
                     completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:JSONObject fromURL:URL]);
                 }
             } else {
                 // object is not supported
                 completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                 return;
             }
         }
         
         if (deleteEveryOtherObject) {
             // now delete every object not returned from the API
             [self deleteObjectsWithoutRemoteIDs:fetchedObjectIDs];
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
         NSMutableArray *updatedObjects = [NSMutableArray array];
         
         if (error) {
             // check for error
             completionHandler(nil, error);
             return;
         } else {
             // success for now
             
             // get relationship description, name of destination entity and the name of the invers relation.
             NSRelationshipDescription *relationshipDescription = [self.class relationshipDescriptionNamed:relationship];
             NSAssert(relationshipDescription != nil, @"There is no relationship %@ for %@", relationship, self.class);
             
             NSString *destinationClassName = relationshipDescription.destinationEntity.managedObjectClassName;
             NSAssert(destinationClassName != nil, @"no managedObjectClassName specified for destinationEntity %@", relationshipDescription.destinationEntity);
             NSString *inverseRelationshipName = relationshipDescription.inverseRelationship.name;
             NSAssert(inverseRelationshipName != nil, @"no inverseRelationshipName specified for relationshipDescription %@", relationshipDescription);
             
             // update attributes based in relationship type
             if (relationshipDescription.isToMany) {
                 // is a 1-to-many relation
                 if (![JSONObject isKindOfClass:NSArray.class]) {
                     // make sure JSONObject has correct class
                     completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                     return;
                 }
                 NSArray *JSONObjectsArray = JSONObject;
                 
                 // enumerate raw JSON objects and update destination entity with these.
                 for (NSDictionary *rawDictionary in JSONObjectsArray) {
                     if (![rawDictionary isKindOfClass:NSDictionary.class]) {
                         // make sure JSONObject has correct class
                         completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                         return;
                     }
                     
                     id object = [NSClassFromString(destinationClassName) updatedObjectWithRawJSONDictionary:rawDictionary];
                     [object setValue:self forKey:inverseRelationshipName];
                     
                     if (object) {
                         [updatedObjects addObject:object];
                     } else {
                         completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:JSONObject fromURL:URL]);
                         return;
                     }
                 }
             } else {
                 if (![JSONObject isKindOfClass:NSDictionary.class]) {
                     // make sure JSONObject has correct class
                     completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                     return;
                 }
                 
                 // update destination entity with JSON object.
                 id object = [NSClassFromString(destinationClassName) updatedObjectWithRawJSONDictionary:JSONObject];
                 [self setValue:object forKey:relationship];
                 
                 if (object) {
                     [updatedObjects addObject:object];
                 } else {
                     completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:JSONObject fromURL:URL]);
                     return;
                 }
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
         
         completionHandler(updatedObjects, nil);
     }];
}

@end



@implementation NSManagedObject (CTRESTfulCoreData)

+ (NSArray *)attributeNames
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self)
                                                         inManagedObjectContext:context];
    
    return entityDescription.attributesByName.allKeys;
}

+ (NSRelationshipDescription *)relationshipDescriptionNamed:(NSString *)relationshipName
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self)
                                                         inManagedObjectContext:context];
    return [entityDescription.relationshipsByName objectForKey:relationshipName];
}

+ (NSManagedObjectContext *)managedObjectContext
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
    }
    
    return mappingModel;
}

+ (CTManagedObjectValidationModel *)validationModelForManagedObjectContext:(NSManagedObjectContext *)context
{
    CTManagedObjectValidationModel *validationModel = objc_getAssociatedObject(self, &CTRESTfulCoreDataValidationModelKey);
    
    if (!validationModel) {
        validationModel = [[CTManagedObjectValidationModel alloc] initWithManagedObjectClassName:NSStringFromClass(self) inManagedObjectContext:context];
        
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
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    CTManagedObjectValidationModel *validationModel = [self validationModelForManagedObjectContext:context];
    
    if (![rawDictionary isKindOfClass:NSDictionary.class]) {
        DLog(@"WARNING: JSON Object is not a NSDictionary (%@)", rawDictionary);
        return nil;
    }
    
    NSString *modelClassName = NSStringFromClass(self);
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
    CTManagedObjectValidationModel *validationModel = [self.class validationModelForManagedObjectContext:self.managedObjectContext];
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

+ (id)objectWithRemoteID:(NSNumber *)ID
{
    NSManagedObjectContext *context = self.managedObjectContext;
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
    NSRelationshipDescription *relationshipDescription = [self.class relationshipDescriptionNamed:relationship];
    NSAssert(relationshipDescription != nil, @"no relationship with name %@ found", relationship);
    
    NSRelationshipDescription *inverseRelationshipDescription = relationshipDescription.inverseRelationship;
    NSAssert(inverseRelationshipDescription != nil, @"invers relationship not found for relationship %@", relationship);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:relationshipDescription.destinationEntity.managedObjectClassName];
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", inverseRelationshipDescription.name, self];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:attribute ascending:YES]];
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSAssert(error == nil, @"error while fetching: %@", error);
    
    return objects;
}

+ (void)deleteObjectsWithoutRemoteIDs:(NSArray *)remoteIDs
{
    NSManagedObjectContext *context = self.managedObjectContext;
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    NSString *idKey = [mappingModel keyForManagedObjectFromJSONObjectKeyPath:@"id"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
    request.predicate = [NSPredicate predicateWithFormat:@"%K NOT IN %@", idKey, remoteIDs];
    
    NSError *error = nil;
    NSArray *objectsToBeDeleted = [context executeFetchRequest:request error:&error];
    NSAssert(error == nil, @"error while fetching: %@", error);
    
    for (id object in objectsToBeDeleted) {
        [context deleteObject:object];
    }
}

@end
