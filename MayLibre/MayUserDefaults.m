//
//  MayUserDefaults.m
//  MayLibre
//
//  Created by Jo Brunner on 02.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MayUserDefaults.h"

@implementation MayUserDefaults

#pragma mark - Singleton

+ (MayUserDefaults *)sharedInstance {
    
    static dispatch_once_t pred;
    static MayUserDefaults *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Init

- (instancetype)init {
    
    if (self = [super init]) {
    }

    preferences = [NSUserDefaults standardUserDefaults];

    return self;
}

#pragma mark - Preference Methods

- (void)setListMarkedEntries:(BOOL)marked {
    
    [preferences setBool:marked
                  forKey:kMayPreferenceListMarkedEntries];
}

- (BOOL)listMarkedEntries {
    
    return [preferences boolForKey:kMayPreferenceListMarkedEntries];
}

- (BOOL)toogleListMarkedEntries {

    BOOL current = self.listMarkedEntries;

    [self setListMarkedEntries:!current];
    
    return !current;
}

@end