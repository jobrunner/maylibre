@import Foundation;

#import "MayTableViewOptions.h"

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

@end
