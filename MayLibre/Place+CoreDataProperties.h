//
//  Place+CoreDataProperties.h
//  MayLibre
//
//  Created by Jo Brunner on 05.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface Place (CoreDataProperties)

+ (NSFetchRequest<Place *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSNumber *radius;
@property (nullable, nonatomic, retain) NSDate *creationTime;
@property (nullable, nonatomic, retain) NSDate *updateTime;
@property (nullable, nonatomic, retain) NSNumber *version;

@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPlaceObject:(Place *)value;
- (void)removePlaceObject:(Place *)value;
- (void)addPlace:(NSSet<Place *> *)values;
- (void)removePlace:(NSSet<Place *> *)values;

@end

NS_ASSUME_NONNULL_END
