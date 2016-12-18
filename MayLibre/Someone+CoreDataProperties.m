//
//  Someone+CoreDataProperties.m
//  MayLibre
//
//  Created by Jo Brunner on 18.12.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "Someone+CoreDataProperties.h"

@implementation Someone (CoreDataProperties)

+ (NSFetchRequest<Someone *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Someone"];
}

@dynamic name;
@dynamic userId;
@dynamic version;
@dynamic creationTime;
@dynamic updateTime;
@dynamic owners;
@dynamic lenders;
@dynamic place;

@end
