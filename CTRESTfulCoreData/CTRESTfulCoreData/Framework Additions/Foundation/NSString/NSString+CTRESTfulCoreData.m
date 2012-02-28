//
//  NSString+CTCoreDataAPI.m
//  CTCoreDataAPI
//
//  Created by Oliver Letterer on 24.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreData.h"

@implementation NSString (CTRESTfulCoreData)

- (NSDate *)CTRESTfulCoreDataDateRepresentation
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = CTRESTfulCoreDataDateFormatString;
    
    return [formatter dateFromString:self];
}

- (NSString *)stringByCamelizingString
{
    NSArray *components = [self componentsSeparatedByString:@"_"];
    
    NSMutableString *camelizedString = [NSMutableString stringWithCapacity:self.length];
    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [camelizedString appendString:component];
        } else {
            if (component.length > 0) {
                NSString *firstLetter = [component substringToIndex:1];
                NSString *restString = [component substringFromIndex:1];
                [camelizedString appendFormat:@"%@%@", firstLetter.uppercaseString, restString];
            }
        }
    }];
    
    return camelizedString;
}

- (NSString *)stringByUnderscoringString
{
    NSString *ret = self;
    
	ret = [ret stringByReplacingOccurrencesOfString:@"([A-Z]+)([A-Z][a-z])" withString:@"$1_$2" options:NSRegularExpressionSearch range:NSMakeRange(0, ret.length)];
    ret = [ret stringByReplacingOccurrencesOfString:@"([a-z\\d])([A-Z])" withString:@"$1_$2" options:NSRegularExpressionSearch range:NSMakeRange(0, ret.length)];
    ret = [ret stringByReplacingOccurrencesOfString:@"-" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ret.length)];
    
	return ret.lowercaseString;
}

@end
