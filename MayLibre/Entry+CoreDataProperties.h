//
//  Entry+CoreDataProperties.h
//  MayLibre
//
//  Created by Jo Brunner on 12.12.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "Entry.h"


NS_ASSUME_NONNULL_BEGIN

@interface Entry (CoreDataProperties)

+ (NSFetchRequest<Entry *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *authors;
@property (nullable, nonatomic, copy) NSString *coverUrl;
@property (nullable, nonatomic, copy) NSDate *creationTime;
@property (nullable, nonatomic, copy) NSNumber *exemplars;
@property (nullable, nonatomic, copy) NSNumber *isMarked;
@property (nullable, nonatomic, copy) NSString *language;
@property (nullable, nonatomic, copy) NSString *mainCategory;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSString *pageCount;
@property (nullable, nonatomic, copy) NSString *place;
@property (nullable, nonatomic, copy) NSString *productCode;
@property (nullable, nonatomic, copy) NSNumber *productCodeType;
@property (nullable, nonatomic, copy) NSString *publisher;
@property (nullable, nonatomic, copy) NSString *publishing;
@property (nullable, nonatomic, copy) NSNumber *referenceType;
@property (nullable, nonatomic, copy) NSString *subtitle;
@property (nullable, nonatomic, copy) NSString *summary;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSDate *updateTime;
@property (nullable, nonatomic, copy) NSString *userFilename;
@property (nullable, nonatomic, copy) NSNumber *version;
@property (nullable, nonatomic, copy) NSString *edition;
@property (nullable, nonatomic, copy) NSNumber *isNew;
@property (nullable, nonatomic, copy) NSString *volume;
@property (nullable, nonatomic, copy) NSString *section;
@property (nullable, nonatomic, copy) NSString *secondaryAuthor;
@property (nullable, nonatomic, copy) NSString *secondaryTitle;
@property (nullable, nonatomic, retain) NSSet<Category *> *category;

@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)addCategoryObject:(Category *)value;
- (void)removeCategoryObject:(Category *)value;
- (void)addCategory:(NSSet<Category *> *)values;
- (void)removeCategory:(NSSet<Category *> *)values;

@end

NS_ASSUME_NONNULL_END
