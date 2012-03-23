//
//  CTManagedObjectMappingModel.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright 2012 ebf. All rights reserved.
//

#import "CTManagedObjectMappingModel.h"
#import "NSString+CTRESTfulCoreData.h"

@interface CTManagedObjectMappingModel ()

- (NSMutableDictionary *)_subclassDictionaryForManagedObjectAttributeName:(NSString *)managedObjectAttributeName;
- (void)_mergeDictionary:(NSMutableDictionary *)thisDictionary withOtherDictionary:(NSMutableDictionary *)otherDictionary;

@end


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
        _registeredSubclassesDictionary = [NSMutableDictionary dictionary];
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

- (void)registerSubclass:(Class)subclass forManagedObjectAttributeName:(NSString *)managedObjectAttributeName withValue:(id)value
{
    NSAssert(subclass, @"subclass cannot be nil");
    NSAssert(managedObjectAttributeName, @"managedObjectAttributeName cannot be nil");
    NSAssert(value, @"value cannot be nil");
    
    NSMutableDictionary *subclassDictionary = [self _subclassDictionaryForManagedObjectAttributeName:managedObjectAttributeName];
    [subclassDictionary setObject:subclass forKey:value];
}

- (Class)subclassForRawJSONDictionary:(NSDictionary *)JSONDictionary
{
    __block Class class = nil;
    
    [_registeredSubclassesDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *managedObjectAttributeName, NSDictionary *subclassesDictionary, BOOL *stop) {
        NSString *JSONObjectKey = [self keyForJSONObjectFromManagedObjectAttribute:managedObjectAttributeName];
        id JSONObjectValue = [JSONDictionary objectForKey:JSONObjectKey];
        
        Class registeredClass = [subclassesDictionary objectForKey:JSONObjectValue];
        if (registeredClass) {
            class = registeredClass;
            *stop = YES;
        }
    }];
    
    return class;
}

- (void)mergeWithMappingModel:(CTManagedObjectMappingModel *)otherMappingModel
{
    [self _mergeDictionary:_managedObjectJSONObjectAttributesDictionary withOtherDictionary:otherMappingModel->_managedObjectJSONObjectAttributesDictionary];
    [self _mergeDictionary:_JSONObjectManagedObjectAttributesDictionary withOtherDictionary:otherMappingModel->_JSONObjectManagedObjectAttributesDictionary];
    [self _mergeDictionary:_valueTransformerHandlers withOtherDictionary:otherMappingModel->_valueTransformerHandlers];
    [self _mergeDictionary:_inverseValueTransformerHandlers withOtherDictionary:otherMappingModel->_inverseValueTransformerHandlers];
    
    [otherMappingModel->_registeredSubclassesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary *otherSubclassDictionary, BOOL *stop) {
        NSMutableDictionary *thisSubclassDictionary = [self _subclassDictionaryForManagedObjectAttributeName:key];
        
        [self _mergeDictionary:thisSubclassDictionary withOtherDictionary:otherSubclassDictionary];
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

#pragma mark - Private category implementation ()

- (NSMutableDictionary *)_subclassDictionaryForManagedObjectAttributeName:(NSString *)managedObjectAttributeName
{
    NSMutableDictionary *subclassDictionary = [_registeredSubclassesDictionary objectForKey:managedObjectAttributeName];
    
    if (!subclassDictionary) {
        subclassDictionary = [NSMutableDictionary dictionary];
        [_registeredSubclassesDictionary setObject:subclassDictionary forKey:managedObjectAttributeName];
    }
    
    return subclassDictionary;
}

- (void)_mergeDictionary:(NSMutableDictionary *)thisDictionary withOtherDictionary:(NSMutableDictionary *)otherDictionary
{
    [otherDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![thisDictionary objectForKey:key]) {
            [thisDictionary setObject:obj forKey:key];
        }
    }];
}

@end
