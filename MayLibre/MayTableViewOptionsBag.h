@import Foundation;

extern NSString *const MayTableViewOptionsBagItemKeyKey;
extern NSString *const MayTableViewOptionsBagItemFieldKey;
extern NSString *const MayTableViewOptionsBagItemAscendingKey;
extern NSString *const MayTableViewOptionsBagItemTextKey;
extern NSString *const MayTableViewOptionsBagItemVisibilityKey;
extern NSString *const MayTableViewOptionsBagItemDisplayOrderKey;

extern NSString *const MayTableViewOptionsBagItemDefaultSortKey;
extern NSString *const MayTableViewOptionsBagItemDefaultFilterKey;

extern NSString *const MayTableViewOptionsBagSectionSort;
extern NSString *const MayTableViewOptionsBagSectionFilter;
extern NSString *const MayTableViewOptionsBagSectionAction;
extern NSString *const MayTableViewOptionsBagSectionDefaults;

@interface MayTableViewOptionsBag : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init;

- (NSDictionary *)optionsFromEntity:(NSString *)entity;

- (NSArray *)sortOptions:(NSString *)entity;

- (NSDictionary *)sortOptionWithKey:(NSInteger)key
                              entry:(NSString *)entity;

- (void)setActiveSortOptionKey:(NSInteger)sortOptionKey
                     forEntity:(NSString *)entity;

- (NSInteger)activeSortOptionKey:(NSString *)entity;

- (NSDictionary *)activeSortOption:(NSString *)entity;

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