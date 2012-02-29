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



@implementation NSManagedObject (CTRESTfulCoreData)

+ (NSArray *)attributeNamesInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self)
                                                         inManagedObjectContext:context];
    
    return entityDescription.attributesByName.allKeys;
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
    
    return [backgroundQueueClass sharedInstance];
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
        objc_setAssociatedObject(self, &CTRESTfulCoreDataValidationModelKey, validationModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return validationModel;
}

+ (void)registerAttributeName:(NSString *)attributeName forJSONObjectKeyPath:(NSString *)JSONObjectKeyPath
{
    CTManagedObjectMappingModel *mappingModel = self.mappingModel;
    
    [mappingModel registerAttribute:attributeName forJSONObjectKeyPath:JSONObjectKeyPath];
}

+ (id)updatedObjectWithRawJSONDictionary:(NSDictionary *)rawDictionary
                  inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSAssert(context != nil, @"No context specified");
    
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
    NSArray *attributes = [self.class attributeNamesInManagedObjectContext:self.managedObjectContext];
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

+ (void)fetchObjectsFromURL:(NSURL *)URL
     inManagedObjectContext:(NSManagedObjectContext *)context
          completionHandler:(void(^)(NSArray *fetchedObjects, NSError *error))completionHandler
{
    [self.backgroundQueue getRequestToURL:URL
                        completionHandler:^(NSArray *JSONObject, NSError *error)
     {
         if (error != nil) {
             completionHandler(nil, error);
         } else if (![JSONObject isKindOfClass:NSArray.class]) {
             completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
         } else {
             // success
             NSMutableArray *updatedObjects = [NSMutableArray arrayWithCapacity:JSONObject.count];
             
             // convert all JSON objects into NSManagedObjects
             for (NSDictionary *rawDictionary in JSONObject) {
                 if (![rawDictionary isKindOfClass:NSDictionary.class]) {
                     completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:JSONObject fromURL:URL]);
                     return;
                 }
                 
                 id object = [self updatedObjectWithRawJSONDictionary:rawDictionary
                                               inManagedObjectContext:context];
                 if (object) {
                     [updatedObjects addObject:object];
                 } else {
                     completionHandler(nil, [NSError CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:JSONObject fromURL:URL]);
                     return;
                 }
             }
             
             completionHandler(updatedObjects, nil);
         }
     }];
}

- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
             inManagedObjectContext:(NSManagedObjectContext *)context
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler
{
    
}

@end
