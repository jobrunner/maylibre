#define kErrorDomainDataCoreStack @"DataCoreStackErrorDomain"

@import Foundation;
@import CoreData;

@interface CoreDataStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithStoreURL:(NSURL*)storeURL
              modelURL:(NSURL*)modelURL;

@end
