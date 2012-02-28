//
//  CTManagedObjectValidationModel.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright 2012 ebf. All rights reserved.
//

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
}

- (id)initWithManagedObjectClassName:(NSString *)managedObjectClassName
              inManagedObjectContext:(NSManagedObjectContext *)context;

- (id)managedObjectObjectFromJSONObjectObject:(id)JSONObjectObject
                    forManagedObjectAttribute:(NSString *)managedObjectAttributeName;

- (id)JSONObjectObjectFromManagedObjectObject:(id)managedObjectObject
                    forManagedObjectAttribute:(NSString *)managedObjectAttributeName;

@end
