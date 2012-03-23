//
//  TTWorkflow.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 23.03.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TTDashboard;

@interface TTWorkflow : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) TTDashboard *dashboard;

@end
