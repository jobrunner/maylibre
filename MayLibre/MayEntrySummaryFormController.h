//
//  MayEntrySummaryFormController.h
//  MayLibre
//
//  Created by Jo Brunner on 01.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import UIKit;
@class Entry;

@interface MayEntrySummaryFormController : UITableViewController <UITextViewDelegate>

@property (nonatomic, strong) Entry *entry;
@property (weak, nonatomic) IBOutlet UITextView *entrySummaryTextView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
