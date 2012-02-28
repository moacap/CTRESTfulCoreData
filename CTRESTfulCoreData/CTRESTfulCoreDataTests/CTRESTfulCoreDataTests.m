//
//  CTRESTfulCoreDataTests.m
//  CTRESTfulCoreDataTests
//
//  Created by Oliver Letterer on 27.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "CTRESTfulCoreDataTests.h"
#import "CTRESTfulCoreData.h"
#import "TTEntity1.h"
#import "Entity2.h"

@implementation CTRESTfulCoreDataTests

- (void)setUp
{
    [super setUp];
    
    [self managedObjectContext];
}

- (void)tearDown
{
    _managedObjectModel = nil;
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testDifferentMappingModels
{
    CTManagedObjectMappingModel *model1 = TTEntity1.mappingModel;
    CTManagedObjectMappingModel *model2 = Entity2.mappingModel;
    
    STAssertNotNil(model1, @"+[NSManagedObject mappingModel] cannot return nil");
    STAssertNotNil(model2, @"+[NSManagedObject mappingModel] cannot return nil");
    
    STAssertTrue(model1 != model2, @"Different entities cannot return the same CTManagedObjectMappingModel");
    
    STAssertEquals(model1, TTEntity1.mappingModel, @"+[NSManagedObject mappingModel] cannot return different models for the same class.");
}

- (void)testMappingModelKeyConversion
{
    CTManagedObjectMappingModel *model = TTEntity1.mappingModel;
    
    NSString *key = [model keyForJSONObjectFromManagedObjectAttribute:@"someStrangeString"];
    NSString *expectedKey = @"some_super_strange_string";
    STAssertEqualObjects(key, expectedKey, @"keyForJSONObjectFromManagedObjectAttribute: not working");
    
    key = [model keyForJSONObjectFromManagedObjectAttribute:@"someDate"];
    expectedKey = @"some_date";
    STAssertEqualObjects(key, expectedKey, @"keyForJSONObjectFromManagedObjectAttribute: not working");
    
    
    
    key = [model keyForManagedObjectFromJSONObjectKeyPath:@"some_super_strange_string"];
    expectedKey = @"someStrangeString";
    STAssertEqualObjects(key, expectedKey, @"keyForManagedObjectFromJSONObjectKeyPath: not working");
    
    key = [model keyForManagedObjectFromJSONObjectKeyPath:@"some_date"];
    expectedKey = @"someDate";
    STAssertEqualObjects(key, expectedKey, @"keyForManagedObjectFromJSONObjectKeyPath: not working");
}

- (void)testAttributeNames
{
    NSArray *attributeNames = [TTEntity1 attributeNamesInManagedObjectContext:_managedObjectContext];
    NSArray *expectedAttributes = [NSArray arrayWithObjects:@"id", @"someDate", @"someNumber", @"someStrangeString", @"someString", nil];
    
    STAssertEqualObjects(attributeNames, expectedAttributes, @"+[NSManagedObject attributeNamesInManagedObjectContext] not returning correct attribute names");
}

- (void)testCreationAndUpdateOfManagedObjectModels
{
    NSURL *URL = [[NSBundle bundleForClass:self.class] URLForResource:@"APISampleEntity" withExtension:@"json"];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:URL]
                                                                   options:0
                                                                     error:NULL];
    
    // update one entity with id 5
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary
                                               inManagedObjectContext:_managedObjectContext];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInt:5], @"id not correct (%@)", entity);
    STAssertEqualObjects(entity.someString, @"String", @"someString not correct (%@)", entity);
    STAssertEqualObjects(entity.someNumber, [NSNumber numberWithInt:7], @"someNumber not correct (%@)", entity);
    STAssertEqualObjects(entity.someStrangeString, @"Super Strange String", @"someStrangeString not correct (%@)", entity);
    STAssertEqualObjects(entity.someDate, @"2012-02-24T08:22:43Z".CTRESTfulCoreDataDateRepresentation, @"someDate not correct (%@)", entity);
    
    // now update the same entity with myID 5 => only one object should exist in the database
    entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary
                                    inManagedObjectContext:_managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(entity.class)];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [NSNumber numberWithInt:5]];
    
    NSError *error = nil;
    NSArray *objects = [_managedObjectContext executeFetchRequest:request
                                                            error:&error];
    
    STAssertNil(error, @"error while fetching");
    STAssertTrue(objects.count == 1, @"only one object should be in the database");
}

- (void)testUpdateWithBadJSONObject
{
    NSURL *URL = [[NSBundle bundleForClass:self.class] URLForResource:@"BADAPISampleEntity" withExtension:@"json"];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:URL]
                                                                   options:0
                                                                     error:NULL];
    
    // update one entity with id 5
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary
                                               inManagedObjectContext:_managedObjectContext];
    
    STAssertNil(entity.someString, @"some_string is badly formatted => entity.someString should not be set (%@)", entity);
    STAssertNil(entity.someDate, @"some_date is badly formatted => entity.someDate should not be set (%@)", entity.someDate);
}

- (void)testUpdateWithJSONObjectWithoutID
{
    NSURL *URL = [[NSBundle bundleForClass:self.class] URLForResource:@"SampleEntityWithoutID" withExtension:@"json"];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:URL]
                                                                   options:0
                                                                     error:NULL];
    
    // update one entity with id 5
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary
                                               inManagedObjectContext:_managedObjectContext];
    
    STAssertNil(entity, @"JSON object without id should not create a CoreData object: %@", entity);
}

- (void)testURLSubstitution
{
    NSURL *URL = [[NSBundle bundleForClass:self.class] URLForResource:@"APISampleEntity" withExtension:@"json"];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:URL]
                                                                   options:0
                                                                     error:NULL];
    
    // update one entity with id 5
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary
                                               inManagedObjectContext:_managedObjectContext];
    
    URL = [NSURL URLWithString:@"http://0.0.0.0:3000/api/root/:id/bla"];
    URL = [URL URLBySubstitutingAttributesWithManagedObject:entity];
    NSURL *expectedURL = [NSURL URLWithString:@"http://0.0.0.0:3000/api/root/5/bla"];
    STAssertEqualObjects(URL, expectedURL, @":id substitution not working");
    
    URL = [NSURL URLWithString:@"http://0.0.0.0:3000/api/root/:id/:some_string"];
    URL = [URL URLBySubstitutingAttributesWithManagedObject:entity];
    expectedURL = [NSURL URLWithString:@"http://0.0.0.0:3000/api/root/5/String"];
    STAssertEqualObjects(URL, expectedURL, @":id and :some_string substitution not working");
    
    URL = [NSURL URLWithString:@"http://0.0.0.0:3000/api/dashboard_content_containers/:id/workflows?updated_at=:some_date"];
    URL = [URL URLBySubstitutingAttributesWithManagedObject:entity];
    expectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://0.0.0.0:3000/api/dashboard_content_containers/5/workflows?updated_at=%@", entity.someDate.CTRESTfulCoreDataDateRepresentation]];
    STAssertEqualObjects(URL, expectedURL, @":some_date substitution not working");
}

#pragma mark - CoreData

- (NSString *)managedObjectModelName
{
    return @"Model";
}

- (NSManagedObjectModel *)managedObjectModel 
{
    if (!_managedObjectModel) {
        NSString *managedObjectModelName = self.managedObjectModelName;
        NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:managedObjectModelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext 
{
    if (!_managedObjectContext) {
        _managedObjectContext = self.newManagedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectContext *)newManagedObjectContext
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = self.persistentStoreCoordinator;
    NSManagedObjectContext *newManagedObjectContext = nil;
    
    if (persistentStoreCoordinator) {
        newManagedObjectContext = [[NSManagedObjectContext alloc] init];
        newManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    }
    
    return newManagedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (!_persistentStoreCoordinator) {
        NSManagedObjectModel *managedObjectModel = self.managedObjectModel;
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}


@end
