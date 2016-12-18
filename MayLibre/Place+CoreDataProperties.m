//
//  Place+CoreDataProperties.m
//  MayLibre
//
//  Created by Jo Brunner on 05.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Place+CoreDataProperties.h"

@implementation Place (CoreDataProperties)

+ (NSFetchRequest<Place *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"Place"];
}

@dynamic name;
@dynamic latitude;
@dynamic longitude;
@dynamic radius;
@dynamic creationTime;
@dynamic updateTime;
@dynamic version;

@end
