//
//  CTRESTfulCoreDataGlobal.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 05.03.12.
//  Copyright 2012 ebf. All rights reserved.
//

typedef id(^CTCustomTransformableValueTransformationHandler)(id object, NSString *managedObjectAttributeName);

#   ifndef __has_feature
#       def    __has_feature 0
#   endif

#   if __has_feature(objc_arc_weak)
#       define __ct_weak __weak
#       define ct_weak weak
#   else
#       define __ct_weak __unsafe_unretained
#       define ct_weak unsafe_unretained
#   endif
