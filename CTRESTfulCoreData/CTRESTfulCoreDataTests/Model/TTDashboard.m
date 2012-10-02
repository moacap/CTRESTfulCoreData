//
//  TTDashboard.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 23.03.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "TTDashboard.h"
#import "TTWorkflow.h"
#import "TTEntity1.h"
#import "CTRESTfulCoreData.h"



@implementation TTDashboard
@dynamic name, workflows, identifier;

+ (void)initialize
{
    [self registerAttributeName:@"identifier" forJSONObjectKeyPath:@"id"];
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
