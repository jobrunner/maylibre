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
#import "MayTableViewOptionsController.h"
#import "FetchedResultsControllerDataSource.h"

@interface MayEntriesController : UITableViewController <
    MayBarCodeScannerDelegate,
    MayTableViewOptionsControllerDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    UISearchResultsUpdating,
    UISearchControllerDelegate,
    UISearchBarDelegate,
    NSFetchedResultsControllerDelegate,
    MFMailComposeViewControllerDelegate,
    MGSwipeTableCellDelegate,
    UIViewControllerTransitioningDelegate,
    FetchedResultsControllerDataSourceDelegate
>

@end
