//
//  CTManagedObjectMappingModel.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright 2012 ebf. All rights reserved.
//



/**
 @class     CTManagedObjectMappingModel
 @abstract  <#abstract comment#>
 */
@interface CTManagedObjectMappingModel : NSObject {
@private
    NSMutableDictionary *_managedObjectJSONObjectAttributesDictionary; // { "myValue" : "my_value" }
    NSMutableDictionary *_JSONObjectManagedObjectAttributesDictionary; // { "my_value" : "myValue" }
}

- (void)registerAttribute:(NSString *)attribute
     forJSONObjectKeyPath:(NSString *)JSONObjectKeyPath;

- (NSString *)keyForJSONObjectFromManagedObjectAttribute:(NSString *)attribute;
- (NSString *)keyForManagedObjectFromJSONObjectKeyPath:(NSString *)JSONObjectKeyPath;

@end
