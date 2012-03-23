//
//  CTManagedObjectMappingModel.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreDataGlobal.h"



/**
 @class     CTManagedObjectMappingModel
 @abstract  <#abstract comment#>
 */
@interface CTManagedObjectMappingModel : NSObject {
@private
    NSMutableDictionary *_managedObjectJSONObjectAttributesDictionary; // { "myValue" : "my_value" }
    NSMutableDictionary *_JSONObjectManagedObjectAttributesDictionary; // { "my_value" : "myValue" }
    
    NSMutableDictionary *_valueTransformerHandlers;
    NSMutableDictionary *_inverseValueTransformerHandlers;
}

- (void)registerAttribute:(NSString *)attribute
     forJSONObjectKeyPath:(NSString *)JSONObjectKeyPath;

- (void)registerValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)valueTransformerHandler
          forManagedObjectAttributeName:(NSString *)managedObjectAttributeName;

- (void)registerInverseValueTransformerHandler:(CTCustomTransformableValueTransformationHandler)inservseValueTransformerHandler
                 forManagedObjectAttributeName:(NSString *)managedObjectAttributeName;

- (void)mergeWithMappingModel:(CTManagedObjectMappingModel *)otherMappingModel;

- (NSString *)keyForJSONObjectFromManagedObjectAttribute:(NSString *)attribute;
- (NSString *)keyForManagedObjectFromJSONObjectKeyPath:(NSString *)JSONObjectKeyPath;

- (CTCustomTransformableValueTransformationHandler)valueTransformerForManagedObjectAttributeName:(NSString *)managedObjectAttributeName;
- (CTCustomTransformableValueTransformationHandler)inverseValueTransformerForManagedObjectAttributeName:(NSString *)managedObjectAttributeName;

@end
