//
//  MayTableViewBag.m
//  MayLibre
//
//  Created by Jo Brunner on 28.08.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MayTableViewOptionsBag.h"

@interface MayTableViewOptionsBag ()

// hold several options for several entites once
//@property (nonatomic, strong) NSDictionary *options;

//@property (nonatomic, strong) NSArray *sortOptions;
//@property (nonatomic, strong) NSArray *filterOptions;
//@property (nonatomic, strong) NSArray *actionOptions;


@end

@implementation MayTableViewOptionsBag {
    
    NSUserDefaults *preferences;
    NSMutableDictionary *options;
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
        preferences = [NSUserDefaults standardUserDefaults];
        options     = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)dealloc {

    abort();
}

#pragma mark Option Handling

- (NSDictionary *)optionsFromEntity:(NSString *)entity {

    NSDictionary *dict = [options objectForKey:entity];

    if (dict != nil) {
    
        return dict;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:entity
                                                     ofType: @"plist"];
    if (path == nil) {
        NSLog(@"MayTableViewOptionsController: '%@.plist' not found", entity);
        
        return nil;
    }

    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"visible = YES"];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder"
                                                         ascending:YES];
    
    NSArray *sortOptions    = [self extractOptions:(NSArray *)[dict objectForKey:@"sort"]
                                         predicate:predicate
                                    sortDescriptor:sortDescriptor];

    NSArray *filterOptions  = [self extractOptions:(NSArray *)[dict objectForKey:@"filter"]
                                         predicate:predicate
                                    sortDescriptor:sortDescriptor];

    NSArray *actionOptions  = [self extractOptions:(NSArray *)[dict objectForKey:@"action"]
                                         predicate:predicate
                                    sortDescriptor:sortDescriptor];
    
    NSDictionary *defaults  = (NSDictionary *)[dict objectForKey:@"defaults"];
    
    NSDictionary *entityOptions = @{@"sort":sortOptions,
                                   @"filter":filterOptions,
                                   @"action":actionOptions,
                                   @"defaults":defaults};
    
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
    
    return [[self optionsFromEntity:entity] objectForKey:@"sort"];
}

- (NSDictionary *)sortOptionWithKey:(NSInteger)key
                              entry:(NSString *)entity {
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tag = %ld", key];
    
    return [[[self sortOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

// @todo: rename setActiveSortOptionKey...
- (void)setSortOptionKey:(NSInteger)sortOption
               forEntity:(NSString *)entity {
    
    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, @"sort"];
    
    [preferences setInteger:sortOption
                     forKey:key];
}

// @todo: rename in activeSortOptionKey
- (NSInteger)sortOptionKey:(NSString *)entity {
    
    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, @"sort"];
    
    NSInteger sortOption = [preferences integerForKey:key];
    
    if (sortOption == 0) {
        NSDictionary *defaults = [[self defaultOptions:entity] objectForKey:@"defaults"];
        sortOption = (NSInteger)[defaults objectForKey:@"sortTag"];
    }
    
    return sortOption;
}

// @todo: rename in activeSortOption
- (NSDictionary *)sortOption:(NSString *)entity {
    
    NSInteger key           = [self sortOptionKey:entity];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tag = %ld", key];
    
    return [[[self sortOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark - Filter functions

- (NSArray *)filterOptions:(NSString *)entity {
    
    return [[self optionsFromEntity:entity] objectForKey:@"filter"];
}

- (NSDictionary *)filterOptionWithKey:(NSInteger)key entry:(NSString *)entity {
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tag = %ld", key];
    
    return [[[self filterOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)setFilterOptionKey:(NSInteger)filterOption
                 forEntity:(NSString *)entity {
    
    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, kMayTableViewOptionsBagSectionFilter];
    
    [preferences setInteger:filterOption
                     forKey:key];
}

- (NSInteger)filterOptionKey:(NSString *)entity {
    
    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, kMayTableViewOptionsBagSectionFilter];
    
    NSInteger filterOption = [preferences integerForKey:key];
    
    if (filterOption == 0) {
        NSDictionary *defaults = [[self defaultOptions:entity] objectForKey:kMayTableViewOptionsBagSectionDefaults];
        filterOption = [[defaults objectForKey:kMayTableViewOptionsBagSectionFilterDefaultId] integerValue];
    }
    
    return filterOption;
}

- (NSDictionary *)filterOption:(NSString *)entity {
    
    NSInteger key           = [self filterOptionKey:entity];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"%@ = %ld", kMayTableViewOptionsBagItemIdKey, key];
    
    return [[[self filterOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark Action Functions

- (NSArray *)actionOptions:(NSString *)entity {
    
    return [[self optionsFromEntity:entity] objectForKey:@"action"];
}

- (NSDictionary *)actionOptionWithKey:(NSInteger)key
                                entry:(NSString *)entity {
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"%@ = %ld", kMayTableViewOptionsBagItemIdKey, key];
    
    return [[[self actionOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark Default functions

- (NSDictionary *)defaultOptions:(NSString *)entity {
    
    return [[self optionsFromEntity:entity] objectForKey:@"defaults"];
}



//- (NSDictionary *)actionOption:(NSString *)entity {
//    
//    NSInteger key           = [self actionOptionKey:entity];
//    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tag = %ld", key];
//    
//    return [[[self actionOptions:entity] filteredArrayUsingPredicate:predicate] firstObject];
//}


//#pragma mark Mark functions
//
//- (void)setListMarkedEntries:(BOOL)marked {
//    
//    [preferences setBool:marked
//                  forKey:kMayPreferenceListMarkedEntries];
//}
//
//- (BOOL)listMarkedEntries {
//    
//    return [preferences boolForKey:kMayPreferenceListMarkedEntries];
//}
//
//- (BOOL)toogleListMarkedEntries {
//    
//    BOOL current = self.listMarkedEntries;
//    
//    [self setListMarkedEntries:!current];
//    
//    return !current;
//}

//#pragma mark depricated

//- (void)setSortField:(NSString *)sortField
//           forEntity:(NSString *)entity
//           ascending:(BOOL)ascending {
//    
//    NSString *sortKey = [NSString stringWithFormat:@"%@.%@",
//                         entity,
//                         @"field"];
//    NSString *ascendingKey = [NSString stringWithFormat:@"%@.%@",
//                              entity,
//                              @"ascending"];
//    
//    [preferences setObject:sortField
//                    forKey:sortKey];
//    [preferences setBool:ascending
//                  forKey:ascendingKey];
//}

//- (NSString *)sortFieldForEntity:(NSString *)entity {
//    
//    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, @"field"];
//    
//    NSString *sortField = (NSString *)[preferences objectForKey:key];
//    
//    if (sortField == nil) {
//        sortField = @"authors";
//    }
//    
//    return sortField;
//}

//- (BOOL)sortAscendingForEntity:(NSString *)entity {
//    
//    NSString *key = [NSString stringWithFormat:@"%@.%@", entity, @"ascending"];
//    
//    return [preferences boolForKey:key];
//}

@end
