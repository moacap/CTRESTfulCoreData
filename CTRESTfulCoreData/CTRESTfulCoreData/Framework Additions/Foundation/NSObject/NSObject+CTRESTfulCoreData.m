//
//  NSObject+CTRESTfulCoreData.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"



@implementation NSObject (CTRESTfulCoreData)

+ (NSString *)classPrefix
{
    NSString *className = NSStringFromClass(self);
    return [[[className.stringByUnderscoringString componentsSeparatedByString:@"_"] objectAtIndex:0] uppercaseString];
}

@end
