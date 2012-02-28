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



@implementation NSManagedObject (CTRESTfulCoreData)

+ (NSArray *)attributeNamesInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self)
                                                         inManagedObjectContext:context];
    
    return entityDescription.attributesByName.allKeys;
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
          completionHandler:(void(^)(NSArray *fetchedObjects, NSError *error))completionHandler
{
    
}

- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler
{
    
}

@end
