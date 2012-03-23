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
#import "TTWorkflow.h"
#import "TTWorkflowSubsclass.h"
#import "TTDashboard.h"



@implementation CTRESTfulCoreDataTests

- (void)setUp
{
    [super setUp];
    
    testContext = [self managedObjectContext];
}

- (void)tearDown
{
    _managedObjectModel = nil;
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
    
    testContext = nil;
    
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
    NSArray *attributeNames = [TTEntity1 attributeNames];
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
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary];
    
    STAssertEqualObjects(entity.id, [NSNumber numberWithInt:5], @"id not correct (%@)", entity);
    STAssertEqualObjects(entity.someString, @"String", @"someString not correct (%@)", entity);
    STAssertEqualObjects(entity.someNumber, [NSNumber numberWithInt:7], @"someNumber not correct (%@)", entity);
    STAssertEqualObjects(entity.someStrangeString, @"Super Strange String", @"someStrangeString not correct (%@)", entity);
    STAssertEqualObjects(entity.someDate, @"2012-02-24T08:22:43Z".CTRESTfulCoreDataDateRepresentation, @"someDate not correct (%@)", entity);
    
    // now update the same entity with myID 5 => only one object should exist in the database
    entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary];
    
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
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary];
    
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
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary];
    
    STAssertNil(entity, @"JSON object without id should not create a CoreData object: %@", entity);
}

- (void)testURLSubstitution
{
    NSURL *URL = [[NSBundle bundleForClass:self.class] URLForResource:@"APISampleEntity" withExtension:@"json"];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:URL]
                                                                   options:0
                                                                     error:NULL];
    
    // update one entity with id 5
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary];
    
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

- (void)testInheritedModelShouldInheritMappingAndValidationModel
{
    // [self registerAttributeName:@"name" forJSONObjectKeyPath:@"__name"];
    // CTManagedObjectMappingModel *workflowMappingModel = [TTWorkflow mappingModel];
    
    // [self registerAttributeName:@"subclassAttribute" forJSONObjectKeyPath:@"__subclass_attribute"];
    CTManagedObjectMappingModel *workflowSubclassMappingModel = [TTWorkflowSubsclass mappingModel];
    
    STAssertEqualObjects([workflowSubclassMappingModel keyForJSONObjectFromManagedObjectAttribute:@"subclassAttribute"], @"__subclass_attribute", @"subclassAttribute wrong");
    STAssertEqualObjects([workflowSubclassMappingModel keyForJSONObjectFromManagedObjectAttribute:@"name"], @"__name", @"mapping model of super class not onherited");
    STAssertEqualObjects([workflowSubclassMappingModel keyForJSONObjectFromManagedObjectAttribute:@"blabla"], @"blabla2", @"mapping model of subsclass should bind stronger than mapping model of super class");
    
    CTManagedObjectValidationModel *subclassValidationModel = [TTWorkflowSubsclass validationModelForManagedObjectContext:testContext];
    
    NSString *convertedName = [subclassValidationModel managedObjectObjectFromJSONObjectObject:@"string" forManagedObjectAttribute:@"subclassAttribute"];
    STAssertEqualObjects(convertedName, @"string", @"validation model not working for subclassAttribute");
    
    convertedName = [subclassValidationModel managedObjectObjectFromJSONObjectObject:@"stringor" forManagedObjectAttribute:@"name"];
    STAssertEqualObjects(convertedName, @"stringor", @"validation model not working for name attribute from super class");
}

- (void)testRelationshipObjectDispatch
{
    NSMutableDictionary *dashboardJSONDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInt:5], @"id",
                                                    @"old name", @"name",
                                                    nil];
    TTDashboard *dashboard = [TTDashboard updatedObjectWithRawJSONDictionary:dashboardJSONDictionary];
    STAssertEqualObjects(dashboard.name, @"old name", @"name wrong");
    STAssertEqualObjects(dashboard.identifier, [NSNumber numberWithInt:5], @"identifier wrong");
    
    [dashboardJSONDictionary setObject:@"name" forKey:@"name"];
    TTDashboard *newDashboard = [TTDashboard updatedObjectWithRawJSONDictionary:dashboardJSONDictionary];
    
    STAssertEquals(newDashboard, dashboard, @"same id should update same object");
    STAssertEqualObjects(newDashboard.name, @"name", @"name wrong");
    
    //    @property (nonatomic, retain) NSString * name;                <-- __name
    //    @property (nonatomic, retain) NSString * type;                <-- type
    //    @property (nonatomic, strong) NSNumber *identifier;           <-- id
    //    @property (nonatomic, retain) NSString * subclassAttribute;   <-- __subclass_attribute
    NSDictionary *workflow1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"workflow1", @"__name",
                               @"plain", @"type",
                               [NSNumber numberWithInt:1], @"id",
                               nil];
    NSDictionary *workflow2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"workflow2", @"__name",
                               @"subclass", @"type",
                               [NSNumber numberWithInt:2], @"id",
                               @"some value", @"__subclass_attribute",
                               nil];
    
    NSArray *JSONArray = [NSArray arrayWithObjects:workflow1, workflow2, nil];
    NSError *error = nil;
    NSArray *updatedObjects = [dashboard updateObjectsForRelationship:@"workflows"
                                                       withJSONObject:JSONArray
                                                              fromURL:nil
                                               deleteEveryOtherObject:YES
                                                                error:&error];
    STAssertNil(error, @"error while updating workflows %@", error);
    
    STAssertEquals(updatedObjects.count, 2u, @"two objects should be updated");
    TTWorkflow *managedWorkflow1 = [updatedObjects objectAtIndex:0];
    TTWorkflowSubsclass *managedWorkflow2 = [updatedObjects objectAtIndex:1];
    
    STAssertEqualObjects(managedWorkflow1.class, TTWorkflow.class, @"managedWorkflow1 has wrong class");
    STAssertEqualObjects(managedWorkflow1.name, @"workflow1", @"name wrong");
    STAssertEqualObjects(managedWorkflow1.type, @"plain", @"type wrong");
    STAssertEqualObjects(managedWorkflow1.identifier, [NSNumber numberWithInt:1], @"id wrong");
    
    STAssertEqualObjects(managedWorkflow2.class, TTWorkflowSubsclass.class, @"managedWorkflow2 has wrong class");
    STAssertEqualObjects(managedWorkflow2.name, @"workflow2", @"name wrong");
    STAssertEqualObjects(managedWorkflow2.type, @"subclass", @"type wrong");
    STAssertEqualObjects(managedWorkflow2.identifier, [NSNumber numberWithInt:2], @"id wrong");
    STAssertEqualObjects(managedWorkflow2.subclassAttribute, @"some value", @"subclassAttribute wrong");
    
    updatedObjects = [newDashboard objectsFromRelationship:@"workflows" sortedByAttribute:@"identifier"];
    STAssertEquals(updatedObjects.count, 2u, @"two objects should be updated");
    managedWorkflow1 = [updatedObjects objectAtIndex:0];
    managedWorkflow2 = [updatedObjects objectAtIndex:1];
    
    STAssertEqualObjects(managedWorkflow1.class, TTWorkflow.class, @"managedWorkflow1 has wrong class");
    STAssertEqualObjects(managedWorkflow1.name, @"workflow1", @"name wrong");
    STAssertEqualObjects(managedWorkflow1.type, @"plain", @"type wrong");
    STAssertEqualObjects(managedWorkflow1.identifier, [NSNumber numberWithInt:1], @"id wrong");
    
    STAssertEqualObjects(managedWorkflow2.class, TTWorkflowSubsclass.class, @"managedWorkflow2 has wrong class");
    STAssertEqualObjects(managedWorkflow2.name, @"workflow2", @"name wrong");
    STAssertEqualObjects(managedWorkflow2.type, @"subclass", @"type wrong");
    STAssertEqualObjects(managedWorkflow2.identifier, [NSNumber numberWithInt:2], @"id wrong");
    STAssertEqualObjects(managedWorkflow2.subclassAttribute, @"some value", @"subclassAttribute wrong");
    
}

- (void)testUnregisteredAttributes
{
    NSDictionary *JSONDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:1331275], @"id",
                                    @"this should not be there", @"unregistered_value",
                                    nil];
    
    TTEntity1 *entity = [TTEntity1 updatedObjectWithRawJSONDictionary:JSONDictionary];
    STAssertNil(entity.unregisteredValue, @"unregisteredValue should not be set.");
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
