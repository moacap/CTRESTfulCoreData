//
//  TTWorkflow.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 23.03.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "TTWorkflow.h"
#import "TTDashboard.h"
#import "TTEntity1.h"
#import "CTRESTfulCoreData.h"
#import "TTWorkflowSubsclass.h"



@implementation TTWorkflow
@dynamic name, dashboard, identifier, type;

+ (void)initialize
{
    [self registerAttributeName:@"name" forJSONObjectKeyPath:@"__name"];
    [self registerAttributeName:@"identifier" forJSONObjectKeyPath:@"id"];
    
    [self registerSubclass:TTWorkflowSubsclass.class forManagedObjectAttributeName:@"type" withValue:@"subclass"];
    
    [self registerAttributeName:@"blabla" forJSONObjectKeyPath:@"blabla1"];
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
