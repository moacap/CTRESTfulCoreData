# CTRESTfulCoreData

CTRESTfulCoreData is a REST interface for CoreData.

## Usage

### Conventions

* Each attribute of a managed object is camelized.
* Each managed object has its own subclass.
* Each JSON object comes with its own `id`.

### Mapping between JSON objects and ManagedObjects

By default, CTRESTfulCoreData maps each attribute of a managed object to an underscored attribute in a JSON object. If your managed object has an attribute `@property (nonatomic, strong) NSString *someString;`, the JSON object is expected to return a string for the key `some_string`. To implement custom attribute mapping, have your subclass implement

```objc
+ (void)initialize
{
    [self registerAttributeName:@"identifier" forJSONObjectKeyPath:@"id"];
}
```