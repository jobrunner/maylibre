//
//  Product.h
//  MayLibre
//
//  Created by Jo Brunner on 26.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum MayProductCodeType : NSUInteger {
    MayProductCodeTypeUnknown = 0,
    MayProductCodeTypeISBN = 1
} MayProductCodeType;

typedef enum MayProductType : NSUInteger {
    MayProductCodeUnknown = 0,
    MayProductTypeBook = 1
} MayProductType;

@interface Product : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Product+CoreDataProperties.h"
