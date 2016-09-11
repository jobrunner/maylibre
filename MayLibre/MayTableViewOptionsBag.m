#import "MayTableViewOptionsBag.h"

NSString *const MayTableViewOptionsBagItemKeyKey                = @"key";
NSString *const MayTableViewOptionsBagItemFieldKey              = @"field";
NSString *const MayTableViewOptionsBagItemAscendingKey          = @"ascending";
NSString *const MayTableViewOptionsBagItemTextKey               = @"textKey";
NSString *const MayTableViewOptionsBagItemVisibilityKey         = @"visible";
NSString *const MayTableViewOptionsBagItemDisplayOrderKey       = @"displayOrder";

NSString *const MayTableViewOptionsBagItemDefaultSortKey        = @"sortKey";
NSString *const MayTableViewOptionsBagItemDefaultFilterKey      = @"filterKey";

NSString *const MayTableViewOptionsBagSectionSort               = @"sort";
NSString *const MayTableViewOptionsBagSectionFilter             = @"filter";
NSString *const MayTableViewOptionsBagSectionAction             = @"action";
NSString *const MayTableViewOptionsBagSectionDefaults           = @"defaults";

@interface MayTableViewOptionsBag ()

@end

@implementation MayTableViewOptionsBag {
    
    NSUserDefaults *preferences;
    NSMutableDictionary *options;
    NSBundle *sourceBundle;
}

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Init

- (instancetype)init {
    
    if (self = [super init]) {

        // internal access to standard user default settings
        preferences  = [NSUserDefaults standardUserDefaults];
        options      = [NSMutableDictionary new];
        sourceBundle = [NSBundle mainBundle];
    }
    
    return self;
}

- (void)dealloc {

    abort();
}

#pragma mark Option Handling

/** 
 * Loads the determined options structure from a <entity>.plist in the main bundle
 */
- (NSDictionary *)optionsFromEntity:(NSString *)entity {

    NSDictionary *dict = [options objectForKey:entity];

    if (dict != nil) {
    
        return dict;
    }
    
    NSString *path = [sourceBundle pathForResource:entity
                                            ofType: @"plist"];
    if (path == nil) {
        NSLog(@"MayTableViewOptionsController: '%@.plist' not found", entity);
        
        return nil;
    }

    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"%K = YES", MayTableViewOptionsBagItemVisibilityKey];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:MayTableViewOptionsBagItemDisplayOrderKey
                                                 ascending:YES];
    
    NSArray *sortOptions;
    sortOptions = [self extractOptions:(NSArray *)[dict objectForKey:MayTableViewOptionsBagSectionSort]
                             predicate:predicate
                        sortDescriptor:sortDescriptor];

    NSArray *filterOptions;
    filterOptions = [self extractOptions:(NSArray *)[dict objectForKey:MayTableViewOptionsBagSectionFilter]
                               predicate:predicate
                          sortDescriptor:sortDescriptor];

    NSArray *actionOptions;
    actionOptions = [self extractOptions:(NSArray *)[dict objectForKey:MayTableViewOptionsBagSectionAction]
                               predicate:predicate
                          sortDescriptor:sortDescriptor];
    
    NSDictionary *defaults  = (NSDictionary *)[dict objectForKey:@"defaults"];
    
    NSDictionary *entityOptions = @{MayTableViewOptionsBagSectionSort:sortOptions,
                                    MayTableViewOptionsBagSectionFilter:filterOptions,
                                    MayTableViewOptionsBagSectionAction:actionOptions,
                                    MayTableViewOptionsBagSectionDefaults:defaults};
    
    [options setObject:entityOptions
                forKey:entity];
    
    return [options objectForKey:entity];
}

- (NSArray *)extractOptions:(NSArray *)sectionOptions
                  predicate:(NSPredicate *)predicate
             sortDescriptor:(NSSortDescriptor *)sortDescriptor {
    
    NSArray *visibleOptions     = [sectionOptions filteredArrayUsingPredicate:predicate];
    NSArray *sortDescriptors    = [NSArray arrayWithObject:sortDescriptor];
    NSArray *orderedOptions     = [visibleOptions sortedArrayUsingDescriptors:sortDescriptors];

    return orderedOptions;
}

#pragma mark Sort function

- (NSArray *)sortOptions:(NSString *)entity {
    
    return [[self optionsFromEntity:entity] objectForKey:MayTableViewOptionsBagSectionSort];
}

- (NSDictionary *)sortOptionWithKey:(NSInteger)key
                              entry:(NSString *)entity {
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"%K = %ld", MayTableViewOptionsBagItemKeyKey, key];

    return [[[self sortOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}


- (void)setActiveSortOptionKey:(NSInteger)sortOptionKey
                     forEntity:(NSString *)entity {
    
    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, MayTableViewOptionsBagSectionSort];
    
    [preferences setInteger:sortOptionKey
                     forKey:key];
}

- (NSInteger)activeSortOptionKey:(NSString *)entity {

    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, MayTableViewOptionsBagSectionSort];
    
    NSInteger sortOption = [preferences integerForKey:key];
    
    if (sortOption == 0) {
        NSDictionary *defaults = [self defaultOptions:entity];

        sortOption = [[defaults objectForKey:MayTableViewOptionsBagItemDefaultSortKey] integerValue];
    }
    
    return sortOption;
}

- (NSDictionary *)activeSortOption:(NSString *)entity {

    NSInteger key = [self activeSortOptionKey:entity];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"%K = %ld", MayTableViewOptionsBagItemKeyKey, key];
    
    return [[[self sortOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark - Filter functions

- (NSArray *)filterOptions:(NSString *)entity {
    
    return [[self optionsFromEntity:entity] objectForKey:@"filter"];
}

- (NSDictionary *)filterOptionWithKey:(NSInteger)key
                                entry:(NSString *)entity {
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tag = %ld", key];
    
    return [[[self filterOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)setFilterOptionKey:(NSInteger)filterOption
                 forEntity:(NSString *)entity {
    
    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, MayTableViewOptionsBagSectionFilter];
    
    [preferences setInteger:filterOption
                     forKey:key];
}

- (NSInteger)filterOptionKey:(NSString *)entity {
    
    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, MayTableViewOptionsBagSectionFilter];
    
    NSInteger filterOption = [preferences integerForKey:key];
    
    if (filterOption == 0) {
        NSDictionary *defaults = [[self defaultOptions:entity] objectForKey:MayTableViewOptionsBagSectionDefaults];
        filterOption = [[defaults objectForKey:MayTableViewOptionsBagItemDefaultFilterKey] integerValue];
    }
    
    return filterOption;
}

- (NSDictionary *)filterOption:(NSString *)entity {
    
    NSInteger key = [self filterOptionKey:entity];

    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"%K = %ld", MayTableViewOptionsBagItemKeyKey, key];
    
    return [[[self filterOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark Action Functions

- (NSArray *)actionOptions:(NSString *)entity {

    return [[self optionsFromEntity:entity] objectForKey:MayTableViewOptionsBagSectionAction];
}

- (NSDictionary *)actionOptionWithKey:(NSInteger)key
                                entry:(NSString *)entity {
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"%K = %ld", MayTableViewOptionsBagItemKeyKey, key];
    
    return [[[self actionOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark Default functions

- (NSDictionary *)defaultOptions:(NSString *)entity {

    return [[self optionsFromEntity:entity] objectForKey:MayTableViewOptionsBagSectionDefaults];
}

@end