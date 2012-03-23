//
//  TTDashboard.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 23.03.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TTWorkflow;

@interface TTDashboard : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *workflows;
@property (nonatomic, strong) NSNumber *identifier;

@end

@interface TTDashboard (CoreDataGeneratedAccessors)

- (void)addWorkflowsObject:(TTWorkflow *)value;
- (void)removeWorkflowsObject:(TTWorkflow *)value;
- (void)addWorkflows:(NSSet *)values;
- (void)removeWorkflows:(NSSet *)values;

@end
