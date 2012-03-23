//
//  CTManagedObjectMappingModel.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright 2012 ebf. All rights reserved.
//

#import "CTManagedObjectMappingModel.h"
#import "NSString+CTRESTfulCoreData.h"



@implementation CTManagedObjectMappingModel

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        // Initialization code
        _managedObjectJSONObjectAttributesDictionary = [NSMutableDictionary dictionary];
        _JSONObjectManagedObjectAttributesDictionary = [NSMutableDictionary dictionary];
        _valueTransformerHandlers = [NSMutableDictionary dictionary];
        _inverseValueTransformerHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - instance methods

- (void)registerAttribute:(NSString *)attribute forJSONObjectKeyPath:(NSString *)JSONObjectKeyPath
{
    NSAssert(attribute != nil, @"No attribute specified");
    NSAssert(JSONObjectKeyPath != nil, @"No JSONObjectKeyPath specified");
    
    [_managedObjectJSONObjectAttributesDictionary setObject:JSONObjectKeyPath forKey:attribute];
    [_JSONObjectManagedObjectAttributesDictionary setObject:attribute forKey:JSONObjectKeyPath];
}

- (void)registerValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)valueTransformerHandler
          forManagedObjectAttributeName:(NSString *)managedObjectAttributeName
{
    [_valueTransformerHandlers setObject:[valueTransformerHandler copy] forKey:managedObjectAttributeName];
}

- (void)registerInverseValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)inservseValueTransformerHandler
                 forManagedObjectAttributeName:(NSString *)managedObjectAttributeName
{
    [_inverseValueTransformerHandlers setObject:[inservseValueTransformerHandler copy] forKey:managedObjectAttributeName];
}

- (void)mergeWithMappingModel:(CTManagedObjectMappingModel *)otherMappingModel
{
    NSLog(@"MERGING with otherMappingModel->_managedObjectJSONObjectAttributesDictionary %@", otherMappingModel->_managedObjectJSONObjectAttributesDictionary);
    [otherMappingModel->_managedObjectJSONObjectAttributesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![_managedObjectJSONObjectAttributesDictionary objectForKey:key]) {
            [_managedObjectJSONObjectAttributesDictionary setObject:obj forKey:key];
        }
    }];
    
    [otherMappingModel->_JSONObjectManagedObjectAttributesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![_JSONObjectManagedObjectAttributesDictionary objectForKey:key]) {
            [_JSONObjectManagedObjectAttributesDictionary setObject:obj forKey:key];
        }
    }];
    
    [otherMappingModel->_valueTransformerHandlers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![_valueTransformerHandlers objectForKey:key]) {
            [_valueTransformerHandlers setObject:obj forKey:key];
        }
    }];
    
    [otherMappingModel->_inverseValueTransformerHandlers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![_inverseValueTransformerHandlers objectForKey:key]) {
            [_inverseValueTransformerHandlers setObject:obj forKey:key];
        }
    }];
}

- (NSString *)keyForJSONObjectFromManagedObjectAttribute:(NSString *)attribute
{
    NSString *key = [_managedObjectJSONObjectAttributesDictionary objectForKey:attribute];
    return key ? key : attribute.stringByUnderscoringString;
}

- (NSString *)keyForManagedObjectFromJSONObjectKeyPath:(NSString *)JSONObjectKeyPath
{
    NSString *key = [_JSONObjectManagedObjectAttributesDictionary objectForKey:JSONObjectKeyPath];
    return key ? key : JSONObjectKeyPath.stringByCamelizingString;
}

- (CTCustomTransformableValueTransformationHandler)valueTransformerForManagedObjectAttributeName:(NSString *)managedObjectAttributeName
{
    return [_valueTransformerHandlers objectForKey:managedObjectAttributeName];
}

- (CTCustomTransformableValueTransformationHandler)inverseValueTransformerForManagedObjectAttributeName:(NSString *)managedObjectAttributeName
{
    return [_inverseValueTransformerHandlers objectForKey:managedObjectAttributeName];
}

@end
