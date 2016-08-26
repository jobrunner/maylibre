//
//  MayEntriesController.h
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import UIKit;
@import CoreData;
@import MessageUI;

#import "MayBarCodeScannerController.h"
#import "MGSwipeTableCell.h"

@interface MayEntriesController : UITableViewController <
    MayBarCodeScannerDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    UISearchResultsUpdating,
    UISearchBarDelegate,
    NSFetchedResultsControllerDelegate,
    MFMailComposeViewControllerDelegate,
    MGSwipeTableCellDelegate>

@end
