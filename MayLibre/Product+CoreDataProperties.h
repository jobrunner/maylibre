//
//  Product+CoreDataProperties.h
//  MayLibre
//
//  Created by Jo Brunner on 27.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface Product (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *productCode;
@property (nullable, nonatomic, retain) NSNumber *productCodeType;
@property (nullable, nonatomic, retain) NSNumber *productType;
@property (nullable, nonatomic, retain) NSString *authors;
@property (nullable, nonatomic, retain) NSString *language;
@property (nullable, nonatomic, retain) NSString *pageCount;
@property (nullable, nonatomic, retain) NSString *publishedDate;
@property (nullable, nonatomic, retain) NSString *publisher;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *subtitle;
@property (nullable, nonatomic, retain) NSString *printType;

@end

NS_ASSUME_NONNULL_END
