//
//  Entry+CoreDataProperties.h
//  MayLibre
//
//  Created by Jo Brunner on 30.05.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Entry.h"
#import "Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface Entry (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *authors;
@property (nullable, nonatomic, retain) NSString *coverUrl;
@property (nullable, nonatomic, retain) NSDate *creationTime;
@property (nullable, nonatomic, retain) NSNumber *isMarked;
@property (nullable, nonatomic, retain) NSString *language;
@property (nullable, nonatomic, retain) NSString *pageCount;
@property (nullable, nonatomic, retain) NSNumber *referenceType;
@property (nullable, nonatomic, retain) NSString *productCode;
@property (nullable, nonatomic, retain) NSString *publishing;
@property (nullable, nonatomic, retain) NSString *publisher;
@property (nullable, nonatomic, retain) NSString *subtitle;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDate *updateTime;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSString *place;
@property (nullable, nonatomic, retain) NSString *summary;
@property (nullable, nonatomic, retain) NSNumber *productCodeType;
@property (nullable, nonatomic, retain) NSSet<Category *> *category;

@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)addCategoryObject:(Category *)value;
- (void)removeCategoryObject:(Category *)value;
- (void)addCategory:(NSSet<Category *> *)values;
- (void)removeCategory:(NSSet<Category *> *)values;

@end

NS_ASSUME_NONNULL_END
