//
//  Entry+CoreDataClass.h
//  MayLibre
//
//  Created by Jo Brunner on 12.12.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

typedef NS_ENUM(NSInteger, MayEntryCodeType) {
    MayEntryCodeTypeUnknown = 0,
    MayEntryCodeTypeISBN = 1,
    MayEntryCodeTypeISSN = 2
};

typedef NS_ENUM(NSInteger, MayEntryMediumType) {
    MayEntryMediumTypeUnknown = 0,
    MayEntryMediumTypeBook = 1,
    MayEntryMediumTypeEBook = 2
};

typedef enum MayEntryType : NSInteger {
    MayEntryTypeArticle = 0,
    MayEntryTypeBook = 1,
    MayEntryTypeBookSection = 7,
    MayEntryTypeEditiedBook = 9
} MayEntryType;

NS_ASSUME_NONNULL_BEGIN


@interface Entry : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Entry+CoreDataProperties.h"
