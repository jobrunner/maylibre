//
//  Someone+CoreDataClass.m
//  MayLibre
//
//  Created by Jo Brunner on 18.12.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "Someone+CoreDataClass.h"
#import "Entry.h"
@implementation Someone

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
