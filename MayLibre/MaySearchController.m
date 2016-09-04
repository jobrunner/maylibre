//
//  maySearchController.m
//  MayLibre
//
//  Created by Jo Brunner on 03.09.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MaySearchController.h"
#import "MaySearchBar.h"

@interface MaySearchController () {

    UISearchBar *_searchBar;
}
@end

@implementation MaySearchController

-(UISearchBar *)searchBar {
    
    if (_searchBar == nil) {
        _searchBar = [[MaySearchBar alloc] initWithFrame:CGRectZero];
    }
    
    return _searchBar;
}

@end
