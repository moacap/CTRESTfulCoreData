//
//  Entity1.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 28.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSManagedObjectContext *testContext;

@interface TTEntity1 : NSManagedObject

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSDate   *someDate;
@property (nonatomic, retain) NSNumber *someNumber;
@property (nonatomic, retain) NSString *someStrangeString;
@property (nonatomic, retain) NSString *someString;

@end
