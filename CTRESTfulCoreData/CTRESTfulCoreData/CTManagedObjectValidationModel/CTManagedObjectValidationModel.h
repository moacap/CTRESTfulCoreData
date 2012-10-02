//
//  CTManagedObjectValidationModel.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreDataGlobal.h"

BOOL NSAttributeTypeIsNSNumber(NSAttributeType attributeType);



/**
 @class     CTManagedObjectValidationModel
 @abstract  <#abstract comment#>
 */
@interface CTManagedObjectValidationModel : NSObject {
@private
    NSString *_managedObjectClassName;
    NSDictionary *_attributTypesValidationDictionary;
    NSDictionary *_valueTransformerNamesDictionary;
    
    CTCustomTransformableValueTransformationHandler _valueTransformationHandler;
    CTCustomTransformableValueTransformationHandler _inverseValueTransformationHandler;
}

@property (nonatomic, copy) CTCustomTransformableValueTransformationHandler valueTransformationHandler;
@property (nonatomic, copy) CTCustomTransformableValueTransformationHandler inverseValueTransformationHandler;

- (id)initWithManagedObjectClassName:(NSString *)managedObjectClassName;

- (id)managedObjectObjectFromJSONObjectObject:(id)JSONObjectObject
                    forManagedObjectAttribute:(NSString *)managedObjectAttributeName;

- (id)JSONObjectObjectFromManagedObjectObject:(id)managedObjectObject
                    forManagedObjectAttribute:(NSString *)managedObjectAttributeName;

@end
