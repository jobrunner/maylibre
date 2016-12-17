//
//  Entry+CoreDataProperties.m
//  MayLibre
//
//  Created by Jo Brunner on 12.12.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "Entry+CoreDataProperties.h"

@implementation Entry (CoreDataProperties)

+ (NSFetchRequest<Entry *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Entry"];
}

@dynamic authors;
@dynamic coverUrl;
@dynamic creationTime;
@dynamic exemplars;
@dynamic isMarked;
@dynamic language;
@dynamic mainCategory;
@dynamic notes;
@dynamic pageCount;
@dynamic place;
@dynamic productCode;
@dynamic productCodeType;
@dynamic publisher;
@dynamic publishing;
@dynamic referenceType;
@dynamic subtitle;
@dynamic summary;
@dynamic title;
@dynamic updateTime;
@dynamic userFilename;
@dynamic version;
@dynamic edition;
@dynamic isNew;
@dynamic volume;
@dynamic section;
@dynamic secondaryAuthor;
@dynamic secondaryTitle;
@dynamic mediumType;
@dynamic category;

@end
