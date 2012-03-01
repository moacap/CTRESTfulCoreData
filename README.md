# CTRESTfulCoreData

CTRESTfulCoreData is a REST interface for CoreData.

## Usage

### Conventions

* Each attribute of a managed object is camelized.
* Each managed object has its own subclass.
* Each JSON object comes with its own `id`.

### What you need to do

* Let each managed object subclass return its `NSManagedObjectContext` in a class method

```objc
+ (NSManagedObjectContext *)managedObjectContext
{
    // only safe on main thread.
    return [[DBDataStoreManager sharedInstance] managedObjectContext];
}
```

* By default, each subclass searches for a backround queue in its namespace. `TTEntity1` will seach for `TTBackgroundQueue`. Overwrite for custom behaviour:

```objc
+ (id<CTRESTfulCoreDataBackgroundQueue>)backgroundQueue
{
    return [ECCommunicationQueue sharedInstance];
}
```

### JSON object attribute validation

Validation is automatically performed based on your managed object model. If an managed object's attribute is a string, CTRESTfulCoreData will only set an attribute iff the corresponding JSON object returns a NSString subsclass for teh given attribute. `NSNull` and other incorrect attributes are automatically filtered out.

Supported attribute types and expected JSON object classes are

* `NSNumber` <=> `NSInteger16AttributeType`, `NSInteger32AttributeType`, `NSInteger64AttributeType`, `NSDecimalAttributeType`, `NSDoubleAttributeType`, `NSFloatAttributeType`, `NSBooleanAttributeType`
* `NSString` <=> `NSStringAttributeType`
* `NSString` <=> `NSDateAttributeType`
  *  Date strings will automatically by converted to NSDate by format specified in CTRESTfulCoreDataDateFormatString.
* `NSTransformableAttributeType` <=> Uses specified value transformer to convert between objects.

### Mapping between JSON objects and ManagedObjects

By default, CTRESTfulCoreData maps each attribute of a managed object to an underscored attribute in a JSON object. If your managed object has an attribute `@property (nonatomic, strong) NSString *someString;`, the JSON object is expected to return a string for the key `some_string`. To implement custom attribute mapping, have your subclass implement

```objc
+ (void)initialize
{
    [self registerAttributeName:@"identifier" forJSONObjectKeyPath:@"id"];
}
```

### Background queue

You need to provide a background queue that conforms to the protocol `CTRESTfulCoreDataBackgroundQueue` and communicates with the network.

## What you get

An easy to use interface for fetching remote JSON objects via

```objc
@interface NSManagedObject (CTRESTfulCoreDataQueryInterface)

+ (void)fetchObjectsFromURL:(NSURL *)URL
          completionHandler:(void(^)(NSArray *fetchedObjects, NSError *error))completionHandler;

- (void)fetchObjectsForRelationship:(NSString *)relationship
                            fromURL:(NSURL *)URL
                  completionHandler:(void (^)(NSArray *fetchedObjects, NSError *error))completionHandler;

@end
```

Fetching objects for relationships supports URL substitution. For each `:some_id` in the URL, CTRESTfulCoreData automatically substitutes the correct value of the calling model.
