//
//  NSError+CTRESTfulCoreData.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 29.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

extern NSString *const CTRESTfulCoreDataErrorDomain;

typedef enum {
    CTRESTfulCoreDataErrorBackgroundQueueReturnedUnexpectedJSONObject,
    CTRESTfulCoreDataErrorJSONDictionaryDidNotConvertIntoManagedObject
} CTRESTfulCoreDataErrorCode;



@interface NSError (CTRESTfulCoreData)

+ (NSError *)CTRESTfulCoreDataErrorBecauseBackgroundQueueReturnedUnexpectedJSONObject:(id)JSONObject fromURL:(NSURL *)URL;
+ (NSError *)CTRESTfulCoreDataErrorBecauseJSONObjectDidNotConvertInManagedObject:(id)JSONObject fromURL:(NSURL *)URL;

@end
