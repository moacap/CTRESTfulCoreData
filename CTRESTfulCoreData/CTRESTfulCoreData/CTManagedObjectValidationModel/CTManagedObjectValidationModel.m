//
//  CTManagedObjectValidationModel.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"

BOOL NSAttributeTypeIsNSNumber(NSAttributeType attributeType)
{
    return NSInteger16AttributeType == attributeType || NSInteger32AttributeType == attributeType || NSInteger64AttributeType == attributeType || NSDecimalAttributeType == attributeType || NSDoubleAttributeType == attributeType || NSFloatAttributeType == attributeType || NSBooleanAttributeType == attributeType;
}



@interface CTManagedObjectValidationModel ()

- (BOOL)_isObject:(id)object validForManagedObjectAttribute:(NSString *)managedObjectAttributeName;
- (id)_convertObject:(id)object forManagedObjectAttribute:(NSString *)managedObjectAttributeName;
- (id)_reverseConvertObject:(id)object forManagedObjectAttribute:(NSString *)managedObjectAttributeName;

@end



@implementation CTManagedObjectValidationModel

#pragma mark - Initialization

- (id)initWithManagedObjectClassName:(NSString *)managedObjectClassName
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (self = [super init]) {
        // Initialization code
        _managedObjectClassName = managedObjectClassName;
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:_managedObjectClassName
                                                             inManagedObjectContext:context];
        
        NSMutableDictionary *attributTypesValidationDictionary = [NSMutableDictionary dictionaryWithCapacity:entityDescription.attributesByName.count];
        NSMutableDictionary *valueTransformerNamesDictionary = [NSMutableDictionary dictionaryWithCapacity:entityDescription.attributesByName.count];
        
        [entityDescription.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attributeDescription, BOOL *stop)
         {
             NSAttributeType attributeType = attributeDescription.attributeType;
             [attributTypesValidationDictionary setObject:[NSNumber numberWithUnsignedInteger:attributeType] forKey:attributeName];
             
             if (attributeType == NSTransformableAttributeType) {
                 NSString *valueTransformerName = attributeDescription.valueTransformerName;
                 NSAssert(valueTransformerName != nil, @"No valueTransformerName specified for attribute %@ of entity %@", attributeName, managedObjectClassName);
                 
                 [valueTransformerNamesDictionary setObject:valueTransformerName forKey:attributeName];
             }
         }];
        
        _attributTypesValidationDictionary = attributTypesValidationDictionary;
        _valueTransformerNamesDictionary = valueTransformerNamesDictionary;
    }
    return self;
}

- (id)managedObjectObjectFromJSONObjectObject:(id)JSONObjectObject
                    forManagedObjectAttribute:(NSString *)managedObjectAttributeName
{
    if ([self _isObject:JSONObjectObject validForManagedObjectAttribute:managedObjectAttributeName]) {
        return [self _convertObject:JSONObjectObject forManagedObjectAttribute:managedObjectAttributeName];
    }
    
    DLog(@"WARNING: Invalid object (%@) for managedObjectAttributeName (%@)", JSONObjectObject, managedObjectAttributeName);
    return nil;
}

- (id)JSONObjectObjectFromManagedObjectObject:(id)managedObjectObject
                    forManagedObjectAttribute:(NSString *)managedObjectAttributeName
{
    return [self _reverseConvertObject:managedObjectObject
             forManagedObjectAttribute:managedObjectAttributeName];
}

#pragma mark - private category implementation ()

- (BOOL)_isObject:(id)object validForManagedObjectAttribute:(NSString *)managedObjectAttributeName
{
    NSAttributeType attributeType = [[_attributTypesValidationDictionary objectForKey:managedObjectAttributeName] unsignedIntegerValue];
    
    if (NSAttributeTypeIsNSNumber(attributeType)) {
        return [object isKindOfClass:NSNumber.class];
    } else if (attributeType == NSStringAttributeType || attributeType == NSDateAttributeType) {
        return [object isKindOfClass:NSString.class];
    } else if (attributeType == NSTransformableAttributeType) {
        return YES;
    }
    
    return NO;
}

- (id)_convertObject:(id)object forManagedObjectAttribute:(NSString *)managedObjectAttributeName
{
    NSAttributeType attributeType = [[_attributTypesValidationDictionary objectForKey:managedObjectAttributeName] unsignedIntegerValue];
    
    if (NSAttributeTypeIsNSNumber(attributeType) || attributeType == NSStringAttributeType) {
        return object;
    } else if (attributeType == NSDateAttributeType) {
        return [(NSString *)object CTRESTfulCoreDataDateRepresentation];
    } else if (attributeType == NSTransformableAttributeType) {
        NSString *valueTransformerName = [_valueTransformerNamesDictionary objectForKey:managedObjectAttributeName];
        NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
        
        return [valueTransformer transformedValue:object];
    }
    
    return nil;
}

- (id)_reverseConvertObject:(id)object forManagedObjectAttribute:(NSString *)managedObjectAttributeName
{
    NSAttributeType attributeType = [[_attributTypesValidationDictionary objectForKey:managedObjectAttributeName] unsignedIntegerValue];
    
    if (NSAttributeTypeIsNSNumber(attributeType) || attributeType == NSStringAttributeType) {
        return object;
    } else if (attributeType == NSDateAttributeType) {
        return [(NSDate *)object CTRESTfulCoreDataDateRepresentation];
    } else if (attributeType == NSTransformableAttributeType) {
        NSString *valueTransformerName = [_valueTransformerNamesDictionary objectForKey:managedObjectAttributeName];
        NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
        
        return [valueTransformer reverseTransformedValue:object];
    }
    
    return nil;
}

@end
