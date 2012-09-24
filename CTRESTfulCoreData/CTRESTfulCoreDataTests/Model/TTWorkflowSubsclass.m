//
//  TTWorkflowSubsclass.m
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 23.03.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "TTWorkflowSubsclass.h"
#import "TTEntity1.h"
#import "CTRESTfulCoreData.h"



@implementation TTWorkflowSubsclass
@dynamic subclassAttribute;

+ (void)initialize
{
    [self registerAttributeName:@"subclassAttribute" forJSONObjectKeyPath:@"__subclass_attribute"];
    
    [self registerAttributeName:@"blabla" forJSONObjectKeyPath:@"blabla2"];
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
