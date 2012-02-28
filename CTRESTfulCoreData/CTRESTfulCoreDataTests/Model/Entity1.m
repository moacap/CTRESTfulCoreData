//
//  Entity1.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "Entity1.h"
#import "CTRESTfulCoreData.h"


@implementation Entity1

@dynamic id;
@dynamic someDate;
@dynamic someNumber;
@dynamic someStrangeString;
@dynamic someString;

+ (void)initialize
{
    [self registerAttributeName:@"someStrangeString"
           forJSONObjectKeyPath:@"some_super_strange_string"];
}

@end
