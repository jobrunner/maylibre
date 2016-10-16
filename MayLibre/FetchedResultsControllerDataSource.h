@import Foundation;
@import UIKit;
@import CoreData;

@class NSFetchedResultsController;
@class FetchedResultsControllerDataSource;

@protocol FetchedResultsControllerDataSourceDelegate

- (NSFetchedResultsController *)fetchedResultsControllerDataSource:(FetchedResultsControllerDataSource *)fetchedResultsControllerDataSource;

@end

@interface FetchedResultsControllerDataSource : NSObject <
    UITableViewDataSource,
    NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readonly) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak) id<FetchedResultsControllerDataSourceDelegate> delegate;

@property (nonatomic, copy) NSString *reuseIdentifier;

// for cell: wenn nib gesetzt wird, wird cell aus einer nib geladen
@property (nonatomic, copy) NSString *nibName;

- (id)initWithTableView:(UITableView*)tableView;

// destroys fetchedResultsController for lazy creation of a new one
- (void)refresh;

@end
