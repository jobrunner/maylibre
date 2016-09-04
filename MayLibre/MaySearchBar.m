//
//  MaySearchBar.m
//  MayLibre
//
//  Created by Jo Brunner on 03.09.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MaySearchBar.h"

@implementation MaySearchBar

- (void)drawRect:(CGRect)rect {

    // this is a hack!
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    rect.size.width = screenWidth;

    // NSLog(@"search bar rect x: %f", rect.origin.x);
    [super drawRect:rect];
}

- (void)setFrame:(CGRect)frame {
    
    // this is a hack!
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    frame.size.width = screenWidth - 16.0;
    frame.origin.x = 8.0;
    // NSLog(@"search bar frame x: %f", frame.origin.x);

    [super setFrame:frame];
}

//- (void)layoutSubviews {
// 
//    [super layoutSubviews];
//
//
//    // resize textfield
//    CGRect frame = self.searchField.frame;
//
//    frame.size.height = ViewHeight;
//    frame.origin.y = ViewMargin;
//    frame.origin.x = ViewMargin;
//    frame.size.width -= ViewMargin / 2;
//    foundSearchTextField.frame = frame;
//}
/*
- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    
    // Do nothing...
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
                    animated:(BOOL)animated {
    
    // Do nothing....
}
*/
@end
