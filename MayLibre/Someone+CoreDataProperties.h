//
//  Someone+CoreDataProperties.h
//  MayLibre
//
//  Created by Jo Brunner on 18.12.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "Someone+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Someone (CoreDataProperties)

+ (NSFetchRequest<Someone *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *version;
@property (nullable, nonatomic, copy) NSDate *creationTime;
@property (nullable, nonatomic, copy) NSDate *updateTime;
@property (nullable, nonatomic, retain) Entry *owners;
@property (nullable, nonatomic, retain) Entry *lenders;
@property (nullable, nonatomic, retain) Place *place;

@end

NS_ASSUME_NONNULL_END
