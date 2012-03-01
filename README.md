# CTRESTfulCoreData

CTRESTfulCoreData is a REST interface for CoreData.

## Usage

### Conventions

* Each attribute of a managed object is camelized.
* Each managed object has its own subclass.
* Each JSON object comes with its own `id`.

### JSON object attribute validation

Validation is automatically performed based on your managed object model. If an managed object's attribute is a string, CTRESTfulCoreData will only set an attribute iff the corresponding JSON object returns a NSString subsclass for teh given attribute. `NSNull` and other incorrect attributes are automatically filtered out.

### Mapping between JSON objects and ManagedObjects

By default, CTRESTfulCoreData maps each attribute of a managed object to an underscored attribute in a JSON object. If your managed object has an attribute `@property (nonatomic, strong) NSString *someString;`, the JSON object is expected to return a string for the key `some_string`. To implement custom attribute mapping, have your subclass implement

```objc
+ (void)initialize
{
    [self registerAttributeName:@"identifier" forJSONObjectKeyPath:@"id"];
}
```