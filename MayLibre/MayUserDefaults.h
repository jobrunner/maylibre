//
//  MayUserDefaults.h
//  MayLibre
//
//  Created by Jo Brunner on 02.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import Foundation;

#define kMayPreferenceListMarkedEntries     @"ListMarkedEntries"

@interface MayUserDefaults : NSObject {
    
    NSUserDefaults *preferences;
}

+ (MayUserDefaults *)sharedInstance;
- (instancetype)init;
- (void)setListMarkedEntries:(BOOL)marked;
- (BOOL)listMarkedEntries;
- (BOOL)toogleListMarkedEntries;
//- (void)setSortField:(NSString *)sortField forEntity:(NSString *)entity ascending:(BOOL)ascending;
//- (NSString *)sortFieldForEntity:(NSString *)entity;
//- (BOOL)sortAscendingForEntity:(NSString *)entity;

@end
