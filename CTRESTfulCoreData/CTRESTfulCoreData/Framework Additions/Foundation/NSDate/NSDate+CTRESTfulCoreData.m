//
//  NSDate+CTCoreDataAPI.m
//  CTCoreDataAPI
//
//  Created by Oliver Letterer on 24.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"

@implementation NSDate (CTRESTfulCoreData)

- (NSString *)CTRESTfulCoreDataDateRepresentation
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:CTRESTfulCoreDataDateFormatString];
    
    return [formatter stringFromDate:self];
}

@end
