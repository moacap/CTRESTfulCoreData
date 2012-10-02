//
//  NSURL+CTRESTfulCoreData.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"

@implementation NSURL (CTRESTfulCoreData)

- (NSURL *)URLBySubstitutingAttributesWithManagedObject:(NSManagedObject *)managedObject
{
    NSString *string = self.relativeString;
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@":[a-z]\\w+"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:NULL];
    
    NSMutableDictionary *substitutionDictionary = [NSMutableDictionary dictionary];
    
    [regularExpression enumerateMatchesInString:string
                                        options:0
                                          range:NSMakeRange(0, string.length)
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                         NSString *attributeKey = [string substringWithRange:result.range];
                                         NSString *JSONObjectKey = [attributeKey substringFromIndex:1];
                                         
                                         CTManagedObjectMappingModel *mappingModel = [managedObject.class mappingModel];
                                         CTManagedObjectValidationModel *validationModel = [managedObject.class validationModel];
                                         
                                         NSString *managedObjectValueKey = [mappingModel keyForManagedObjectFromJSONObjectKeyPath:JSONObjectKey];
                                         id value = [managedObject valueForKey:managedObjectValueKey];
                                         value = [validationModel JSONObjectObjectFromManagedObjectObject:value
                                                                                forManagedObjectAttribute:managedObjectValueKey];
                                         
                                         [substitutionDictionary setObject:value ?: @"" forKey:attributeKey];
                                     }];
    
    NSMutableString *finalURLString = string.mutableCopy;
    [substitutionDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [finalURLString replaceOccurrencesOfString:key
                                        withString:[NSString stringWithFormat:@"%@", obj]
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, finalURLString.length)];
    }];
    
    return [NSURL URLWithString:finalURLString];
}

@end
