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



@implementation TTWorkflow
@dynamic name, dashboard;

+ (void)initialize
{
    [self registerAttributeName:@"name" forJSONObjectKeyPath:@"__name"];
    
    [self registerAttributeName:@"blabla" forJSONObjectKeyPath:@"blabla1"];
}

+ (NSManagedObjectContext *)managedObjectContext
{
    return testContext;
}

@end
