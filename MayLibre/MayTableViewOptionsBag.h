@import Foundation;

#import "MayTableViewOptions.h"

//#define kMayPreferenceListMarkedEntries     @"ListMarkedEntries"

@interface MayTableViewOptionsBag : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init;

- (NSArray *)sortOptions:(NSString *)entity;
- (NSDictionary *)sortOptionWithKey:(NSInteger)key
                              entry:(NSString *)entity;

// @todo: rename setActiveSortOptionKey...
- (void)setSortOptionKey:(NSInteger)sortOption
               forEntity:(NSString *)entity;

// @todo: rename in activeSortOptionKey
- (NSInteger)sortOptionKey:(NSString *)entity;

// @todo: rename in activeSortOption
- (NSDictionary *)sortOption:(NSString *)entity;

// filter
- (NSArray *)filterOptions:(NSString *)entity;
- (NSDictionary *)filterOptionWithKey:(NSInteger)key
                                entry:(NSString *)entity;

- (void)setFilterOptionKey:(NSInteger)filterOption
                 forEntity:(NSString *)entity;

- (NSInteger)filterOptionKey:(NSString *)entity;
- (NSDictionary *)filterOption:(NSString *)entity;

// action
- (NSArray *)actionOptions:(NSString *)entity;

- (NSDictionary *)actionOptionWithKey:(NSInteger)key
                                entry:(NSString *)entity;


// defaults
- (NSDictionary *)defaultOptions:(NSString *)entity;



//- (NSInteger)sortOptionKey:(NSString *)entity;
//- (NSDictionary *)sortOptionWithKey:(NSInteger)key entry:(NSString *)entity;
//
//- (void)setSortOptionKey:(NSInteger)sortOption forEntity:(NSString *)entity;

//- (NSArray *)filterOptions:(NSString *)entity;
//- (void)setFilterOptionKey:(NSInteger)filterOption forEntity:(NSString *)entity;

//- (NSDictionary *)sortOption:(NSString *)entity;

//- (NSArray *)actionOptions:(NSString *)entity;
//- (NSDictionary *)defaultOptions:(NSString *)entity;
//
//- (NSDictionary *)actionOptionWithKey:(NSInteger)key entry:(NSString *)entity;

//- (void)setListMarkedEntries:(BOOL)marked;
//- (BOOL)listMarkedEntries;
//- (BOOL)toogleListMarkedEntries;
//- (void)setSortField:(NSString *)sortField forEntity:(NSString *)entity ascending:(BOOL)ascending;
//- (NSString *)sortFieldForEntity:(NSString *)entity;
//- (BOOL)sortAscendingForEntity:(NSString *)entity;

@end
