#import "Entry.h"

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
