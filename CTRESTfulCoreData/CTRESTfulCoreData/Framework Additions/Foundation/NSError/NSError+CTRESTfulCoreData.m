//
//  NSError+CTRESTfulCoreData.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 29.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"

NSString *const CTRESTfulCoreDataErrorDomain = @"CTRESTfulCoreDataErrorDomain";



@implementation NSError (CTRESTfulCoreData)

+ (NSError *)CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:(id)JSONObject fromURL:(NSURL *)URL
{
    NSString *localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"API return an unexpected JSON object (%@) from URL %@.", @""), JSONObject, URL];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:localizedDescription
                                                         forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:CTRESTfulCoreDataErrorDomain
                               code:CTRESTfulCoreDataErrorBackgroundQueueReturnedUnexpectedJSONObject
                           userInfo:userInfo];
}

+ (NSError *)CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:(id)JSONObject fromURL:(NSURL *)URL
{
    NSString *localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"API return an unexpected JSON object (%@) which cannot be converted into an NSManagedObject from URL %@.", @""), JSONObject, URL];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:localizedDescription
                                                         forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:CTRESTfulCoreDataErrorDomain
                               code:CTRESTfulCoreDataErrorJSONDictionaryDidNotConvertIntoManagedObject
                           userInfo:userInfo];
}

@end
