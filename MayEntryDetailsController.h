//
//  MayEntryDetailsController.h
//  MayLibre
//
//  Created by Jo Brunner on 02.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
@import UIKit;

@class Entry;

@interface MayEntryDetailsController : UITableViewController <
    UITextFieldDelegate,
    UITextViewDelegate>

@property (nonatomic, strong) Entry *entry;

@end
