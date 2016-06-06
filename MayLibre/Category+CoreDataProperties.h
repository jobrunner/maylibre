//
//  Category+CoreDataProperties.h
//  MayLibre
//
//  Created by Jo Brunner on 05.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface Category (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *creationTime;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *updateTime;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSSet<Entry *> *entry;

@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addEntryObject:(Entry *)value;
- (void)removeEntryObject:(Entry *)value;
- (void)addEntry:(NSSet<Entry *> *)values;
- (void)removeEntry:(NSSet<Entry *> *)values;

@end

NS_ASSUME_NONNULL_END
