//
//  Place.m
//  MayLibre
//
//  Created by Jo Brunner on 05.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "Place.h"

@implementation Place

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
