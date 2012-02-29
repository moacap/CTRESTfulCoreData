//
//  CTRESTfulCoreData.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "NSDate+CTRESTfulCoreData.h"
#import "NSError+CTRESTfulCoreData.h"
#import "NSObject+CTRESTfulCoreData.h"
#import "NSString+CTRESTfulCoreData.h"
#import "NSURL+CTRESTfulCoreData.h"

#import "NSManagedObject+CTRESTfulCoreData.h"
#import "CTManagedObjectMappingModel.h"
#import "CTManagedObjectValidationModel.h"

/**
 Format string with which dates will be converted. Default is @"yyyy-MM-dd'T'HH:mm:ss'Z'".
 */
extern NSString *CTRESTfulCoreDataDateFormatString;
