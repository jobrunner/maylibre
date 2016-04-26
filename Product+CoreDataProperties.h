//
//  Product+CoreDataProperties.h
//  MayLibre
//
//  Created by Jo Brunner on 26.04.16.
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

@end

NS_ASSUME_NONNULL_END
