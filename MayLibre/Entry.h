//
//  Product.h
//  MayLibre
//
//  Created by Jo Brunner on 27.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum MayEntryCodeType : NSInteger {
    MayEntryCodeTypeUnknown = 0,
    MayEntryCodeTypeISBN = 1,
    MayEntryCodeTypeISSN = 2
} MayEntryCodeType;

typedef enum MayEntryType : NSInteger {
    MayEntryTypeArticle = 0,
    MayEntryTypeBook = 1,
    MayEntryTypeBookSection = 7,
    MayEntryTypeEditiedBook = 9
} MayEntryType;

NS_ASSUME_NONNULL_BEGIN

@interface Entry : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Entry+CoreDataProperties.h"
