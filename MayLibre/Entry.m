//
//  Entry+CoreDataClass.m
//  MayLibre
//
//  Created by Jo Brunner on 12.12.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "Entry.h"
#import "Category.h"

@implementation Entry

- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    [self setPrimitiveValue:date forKey:@"creationTime"];
    [self setPrimitiveValue:date forKey:@"updateTime"];
}

- (void)willSave {
    
    [super willSave];
    
    if (self.isDeleted) {
        
        return;
    }
    
    NSDate *date = [NSDate date];
    
    [self setPrimitiveValue:date
                     forKey:@"updateTime"];
    
    [self setPrimitiveValue:self.version
                     forKey:@"version"];
}

@end
