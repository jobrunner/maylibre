@import Foundation;
@import CoreData;

#import "Store.h"
#import "CoreDataStack.h"

@interface Store()

@property (nonatomic, strong, readwrite) CoreDataStack *coreData;

@end

@implementation Store

#pragma mark Initializer

- (id)init {

    return [self initWithStoreURL:self.storeURL
                         modelURL:self.modelURL];
}

- (id)initWithStoreURL:(NSURL*)storeURL
              modelURL:(NSURL*)modelURL {

    if (self = [super init]) {
        self.coreData = [[CoreDataStack alloc] initWithStoreURL:storeURL
                                                       modelURL:modelURL];
    }
    
    return self;
}

#pragma mark - Persistence Configuration

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSURL*)storeURL {
    
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MayLibre.sqlite"];
}

- (NSURL*)modelURL {
    
    return [[NSBundle mainBundle] URLForResource:@"MayLibre"
                                   withExtension:@"momd"];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    return self.coreData.managedObjectContext;
}

/**
 * Saves object graph to persisent layer
 */
- (BOOL)save:(NSError **)error {
    
    if (self.coreData.managedObjectContext != nil) {
        
        if ([self.coreData.managedObjectContext hasChanges]) {
        
            return [self.coreData.managedObjectContext save:error];
        }
    }
    
    return NO;
}

/**
 * Removes object from object graph. You must save the graph to persist changes.
 */
- (void)deleteObject:(NSManagedObject *)object {
    
    [self.coreData.managedObjectContext deleteObject:object];
}

@end
