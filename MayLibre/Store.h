// Service Layer

@class CoreDataStack;

@interface Store : NSObject

@property (nonatomic, strong, readonly) CoreDataStack *coreData;
@property (nonatomic, strong, readonly) NSManagedObjectContext* managedObjectContext;

// facade methods
- (BOOL)save:(NSError **)error;
- (void)deleteObject:(NSManagedObject *)object;

@end
