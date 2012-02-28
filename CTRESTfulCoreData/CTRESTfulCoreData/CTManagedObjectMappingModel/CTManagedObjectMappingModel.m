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

@end
