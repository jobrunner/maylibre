#import "CoreDataStack.h"

@interface CoreDataStack()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSURL* modelURL;
@property (nonatomic, strong) NSURL* storeURL;

@end

@implementation CoreDataStack

- (id)initWithStoreURL:(NSURL*)storeURL
              modelURL:(NSURL*)modelURL {
    
    if (self = [super init]) {
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        
        [self setupManagedObjectContext];
    }

    return self;
}

- (void)setupManagedObjectContext {
    
    NSError *error = nil;

    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;

    self.managedObjectContext.persistentStoreCoordinator = coordinator;

    if (error) {
        NSLog(@"error: %@", error);
    }
    
    self.managedObjectContext.undoManager = [NSUndoManager new];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        
        return _managedObjectContext;
    }

    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    return _managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        
        return _managedObjectModel;
    }
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@YES};
    
    NSError *error = nil;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:self.storeURL
                                                         options:options
                                                           error:&error]) {

        NSMutableDictionary *dict = NSMutableDictionary.dictionary;

        dict[NSLocalizedDescriptionKey]         = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey]  = @"There was an error creating or loading the application's saved data.";
        dict[NSUnderlyingErrorKey]              = error;
        
        error = [NSError errorWithDomain:kErrorDomainDataCoreStack
                                    code:23
                                userInfo:dict];
        
        [[NSFileManager defaultManager] removeItemAtURL:self.storeURL
                                                  error:nil];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
