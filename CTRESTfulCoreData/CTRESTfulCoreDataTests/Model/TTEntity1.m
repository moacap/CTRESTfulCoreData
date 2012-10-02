//
//  Entity1.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "TTEntity1.h"
#import "CTRESTfulCoreData.h"

NSManagedObjectContext *testContext;



@implementation TTEntity1

@dynamic id;
@dynamic someDate;
@dynamic someNumber;
@dynamic someStrangeString;
@dynamic someString;
@dynamic unregisteredValue;

+ (void)initialize
{
    [self unregisterAttributeName:@"unregisteredValue"];
    [self registerAttributeName:@"someStrangeString" forJSONObjectKeyPath:@"some_super_strange_string"];
}

+ (NSManagedObjectContext *)mainThreadManagedObjectContext
{
    return testContext;
}

+ (NSManagedObjectContext *)backgroundThreadManagedObjectContext
{
    return testContext;
}

@end
