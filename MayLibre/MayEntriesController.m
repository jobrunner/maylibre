//
//  MayEntriesController.m
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
#import "AppDelegate.h"
#import "MayEntriesController.h"
#import "MayEntryFormController.h"
#import "MayEntryDetailsController.h"
#import "MayEntryCell.h"
#import "MayBarCodeScannerController.h"
#import "MayISBN.h"
#import "MayISBNFormatter.h"
#import "MayISBNGoogleResolver.h"
#import "MayDigest.h"
#import "Entry.h"
#import "MayImageManager.h"
#import "NSString+MayDisplayExtension.h"
#import "MayUserDefaults.h"
#import "MayTableViewOptionsTransitionAnimator.h"
#import "MaySearchController.h"

@interface MayEntriesController() {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

typedef void (^MayActionCompletionHandler)(NSError *error);

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *markBarButton;
@property (nonatomic, weak) IBOutlet UIView *searchBarView;
- (IBAction)scanBarButtonSelected:(UIBarButtonItem *)sender;
- (IBAction)actionBarButtonSelected:(UIBarButtonItem *)sender;
- (IBAction)markBarButtonSelected:(UIBarButtonItem *)sender;

@end

@implementation MayEntriesController

#pragma mark UIViewControllerDelegates

- (void)viewDidLoad {

    [super viewDidLoad];

    managedObjectContext = App.managedObjectContext;
    
    _searchResults = [NSMutableArray new];
    
    [self configureSearch];
    [self hideSearchBarAnimated:YES];

    [self showOptionsBarButton];
    
    NSLog(@"contentOffset.y = %f", self.tableView.contentOffset.y);
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
  
    [self listMarkedEntries:[MayUserDefaults.sharedInstance listMarkedEntries]];
    
    [self.navigationController setToolbarHidden:NO
                                       animated:animated];
//    if (!_searchController.active) {
//        NSLog(@"search controller not active, ")
//        [self hideSearchBarAnimated:NO];
//    }
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"openScannerSegue"]) {
        
        MayBarCodeScannerController *controller =
        (MayBarCodeScannerController *)segue.destinationViewController;
        controller.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"openEntryDetailsSegue"]) {
        
        MayEntryDetailsController *controller =
        (MayEntryDetailsController *)segue.destinationViewController;
        
        MayEntryCell *cell = sender;
        Entry *model = [self.fetchedResultsController objectAtIndexPath:cell.indexPath];
        
        controller.entry = model;
    }
    
    if ([segue.identifier isEqualToString:@"openEntryFormSegue"]) {
        
        MayEntryFormController *controller =
        (MayEntryFormController *)segue.destinationViewController;
        
        MayEntryCell *cell = sender;
        Entry *model = [self.fetchedResultsController objectAtIndexPath:cell.indexPath];
        
        controller.entry = model;
    }
    
    if ([segue.identifier isEqualToString:@"tableViewOptionsSegue"]) {
        
        self.definesPresentationContext = YES;

        UINavigationController *navigationController = segue.destinationViewController;
        
        navigationController.definesPresentationContext = NO;
        navigationController.providesPresentationContextTransitionStyle = YES;
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate = self;
        
        MayTableViewOptionsController *controller =
        [navigationController.viewControllers firstObject];
        controller.entity = @"Entry";
        controller.delegate = self;
    }
}

#pragma mark UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = searchController.searchBar.text;
    
    [self filterContentForSearchText:searchString
                               scope:nil];
    
    [self.tableView reloadData];
}

//#pragma mark UISearchBarDelegate
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//
//    NSLog(@"cancel clicked");
//}

#pragma mark UISearchControllerDelegate

//- (void)didPresentSearchController:(UISearchController *)searchController {
//
//    if (searchController != _searchController) {
//        
//        return;
//    }
//    
//    // hide bar buttons on the right
//    for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
//        item.enabled = NO;
//        item.tintColor = UIColor.clearColor;
//    }
//}

//- (void)didDismissSearchController:(UISearchController *)searchController {
//
//    if (searchController != _searchController) {
//        
//        return;
//    }
//    
//    // show bar buttons on the right
//    for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
//        item.enabled = YES;
//        item.tintColor = nil;
//    }
//}

#pragma mark  UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(MayEntryCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Entry *model;
    if (_searchController.active) {
        model = [self.searchResults objectAtIndex:indexPath.row];
    }
    else {
        model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    [cell configureWithModel:model
                 atIndexPath:indexPath
                withDelegate:self];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    // @todo: Autolayout!!!
    return 80; // @todo: check autolayout height in xib file!
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MayEntryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"openEntryDetailsSegue"
                              sender:cell];
}

/**
 * Supresses header
 */
- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {

    return 0.01;
}

/**
 * Supresses footer
 */
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchController.active) {
        
        return [self.searchResults count];
    }
    
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"MayEntryCell";
    
    MayEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:cellId
                                              bundle:nil]
        forCellReuseIdentifier:cellId];
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.searchController.active) {
        
        return 1;
    }
    
    return [[self.fetchedResultsController sections] count];
}

/**
 * Dosn't support native editing of table view cells.
 */
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

/**
 * Dosn't support conditional rearranging of the table view.
 */
- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

//- (NSString *)tableView:(UITableView *)tableView
//titleForHeaderInSection:(NSInteger)section
//{
//    if (!self.searchController.active) {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//        
//        return [sectionInfo name];
//    }
//    return nil;
//}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//
//    if (self.searchController.active) {
//        return nil;
//        
//    }
//
//    NSMutableArray *index = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
//    NSArray *initials = [self.fetchedResultsController sectionIndexTitles];
//    [index addObjectsFromArray:initials];
//    
//    return index;
//}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    
    if (self.searchController.active) {
        
        return 0;
    }
    
    if (index > 0) {
        // The index is offset by one to allow for the extra search icon inserted at the front of the index
        return [self.fetchedResultsController sectionForSectionIndexTitle:title
                                                                  atIndex:(index - 1)];
    }
    else {
        // The first entry in the index is for the search icon so we return section not found and force the table to scroll to the top.
        CGRect searchBarFrame = self.searchController.searchBar.frame;
        
        [self.tableView scrollRectToVisible:searchBarFrame
                                   animated:NO];
        
        return NSNotFound;
    }
}

#pragma mark MGSwipeTableCellDelegates

- (BOOL)swipeTableCell:(MayEntryCell *)cell
   tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction
         fromExpansion:(BOOL)fromExpansion {
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        
        [self deleteRecordFromCell:cell];
        
        return NO;
    }
    
    if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        
        [self toggleMarkFromCell:cell];
    }
    
    if (direction == MGSwipeDirectionRightToLeft && index == 2) {
        // Send an email with sample data
        [self sendMail:[self.fetchedResultsController objectAtIndexPath:cell.indexPath]];
    }
    
    return YES;
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

#pragma mark MFMailComposeViewControllerDelegates

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {

    MayTableViewOptionsTransitionAnimator *animator =
    [MayTableViewOptionsTransitionAnimator new];
    
    animator.presenting = YES;

    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44.5);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - 0.5,
                                                                headerView.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [headerView addSubview:lineView];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
    [self.navigationController setToolbarHidden:YES
                                       animated:YES];

    // replace search bar in table header view against a
    // dummy navigation bar that will be shown behind the
    // TableViewOptions...
    [self.tableView setTableHeaderView:headerView];
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

    MayTableViewOptionsTransitionAnimator *animator = [MayTableViewOptionsTransitionAnimator new];
    animator.presenting = NO;
    
    [self.tableView setTableHeaderView:nil];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    [self.navigationController setToolbarHidden:NO
                                       animated:YES];
    // restore search bar in table header view:
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self hideSearchBarAnimated:YES];
    
    return animator;
}

#pragma mark - MAYBarCodeScannerDelegates

- (void)barCodeScannerController:(MayBarCodeScannerController *)controller
                  didCaptureISBN:(MayISBN *)isbn {
    
    [self storeEntryWithISBNAsyc:isbn];
}

#pragma mark MaySortOptionsControllerDelegate

- (void)tableViewOptionsController:(MayTableViewOptionsController *)controller
               didSelectSortOption:(NSDictionary *)sortOption {
    
    [self sortBy:[sortOption objectForKey:kMayTableViewOptionsBagItemFieldKey]
       ascending:[sortOption valueForKey:kMayTableViewOptionsBagItemAscendingKey]];
}

- (void)tableViewOptionsController:(MayTableViewOptionsController *)controller
             didSelectFilterOption:(NSDictionary *)filterOption {

    // apply filter
    NSLog(@"MayEntriesController. Ändere Filter %@", filterOption);
}

#pragma mark IBActions

/**
 * Triggers bar code scanning
 */
- (IBAction)scanBarButtonSelected:(UIBarButtonItem *)sender {
    
    [self performSegueWithIdentifier:@"openScanner"
                              sender:sender];
}

- (IBAction)actionBarButtonSelected:(UIBarButtonItem *)sender {

    // open action sheet showing what actions can be performed
    
    UIAlertController *actionSheet =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *exportAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Export all Entries", nil)
                             style:UIAlertActionStyleDefault
                           handler:nil];
    
    UIAlertAction *addEntryAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Book Title", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               [self performSegueWithIdentifier:@"createEntryFormSegue"
                                                         sender:self];
                           }];

    UIAlertAction *addEntryWithISBNAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Add with ISBN", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               [self addISBNManualy];
                           }];
    
//    UIAlertAction *settingsAction =
//    [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil)
//                             style:UIAlertActionStyleDefault
//                           handler:nil];

    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:nil];

    [actionSheet addAction:addEntryAction];
    [actionSheet addAction:addEntryWithISBNAction];
    [actionSheet addAction:exportAction];
//    [actionSheet addAction:settingsAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

- (IBAction)markBarButtonSelected:(UIBarButtonItem *)sender {

    [self listMarkedEntries:[MayUserDefaults.sharedInstance toogleListMarkedEntries]];
    
    [self.tableView reloadData];
}

#pragma mark MayEntriesController

/**
 *
 */
- (void)sortBy:(NSString *)sortField
     ascending:(BOOL)ascending {
    
    [[MayUserDefaults sharedInstance] setSortField:sortField
                                         forEntity:@"entry"
                                         ascending:ascending];
    
    [self refreshFetchedResultsController];
    [self.tableView reloadData];
}

/**
 * Configures search bar and search controller
 */
- (void)configureSearch {

    self.definesPresentationContext = YES;

    [UISearchBar appearance].barTintColor = UIColor.whiteColor;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];

    _searchController.searchBar.backgroundColor = [UIColor whiteColor];
    _searchController.searchBar.translucent = NO;
    _searchController.searchBar.delegate = self;
    _searchController.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = YES;

    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self;

    self.tableView.tableHeaderView = _searchController.searchBar;
}

- (void)hideSearchBarAnimated:(BOOL)animated {

    CGPoint searchBarOffset = CGPointMake(0.0, 44.0 + self.tableView.contentOffset.y);
    [self.tableView setContentOffset:searchBarOffset
                            animated:animated];
}

- (void)showOptionsBarButton {
    
    UIBarButtonItem *optionsBarButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sorting-sm"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(optionsBarButtonTap:)];
    
    self.navigationItem.rightBarButtonItem = optionsBarButton;
}

- (void)hideOptionsBarButton {

    self.navigationItem.rightBarButtonItem = nil;
}

- (void)optionsBarButtonTap:(UIBarButtonItem *)item {
    
    [self performSegueWithIdentifier:@"tableViewOptionsSegue"
                              sender:self];
}

/**
 * Handles swipe action: Deletes record from table view cell and managed object
 */
- (void)deleteRecordFromCell:(MayEntryCell *)cell {
    
    void (^action)() = ^{
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error localizedDescription]);
        }
    };
    
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction;
    deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Entry", nil)
                                            style:UIAlertActionStyleDestructive
                                          handler:action];
    UIAlertAction *cancelAction;
    cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                            style:UIAlertActionStyleCancel
                                          handler:nil];
    [actionSheet addAction:deleteAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

/**
 * Handles swipe action: mark record
 */
- (void)toggleMarkFromCell:(UITableViewCell *)cell {
    
    // Mark sample
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    Entry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // toogle isMarked flag
    entry.isMarked = ([entry.isMarked boolValue]) ? @NO : @YES;
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        return [App viewController:self
                   handleUserError:error
                             title:nil];
    }
}

/**
 * Assables sort descriptors for table view.
 * Function depends on segmentation control.
 */
- (NSArray *)sortDescriptors {
    
    NSString *sortField = [[MayUserDefaults sharedInstance] sortFieldForEntity:@"entry"];
    BOOL ascending = [[MayUserDefaults sharedInstance] sortAscendingForEntity:@"entry"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField
                                                                   ascending:ascending];
    return @[sortDescriptor];
}

- (void)refreshFetchedResultsController {
    
    NSLog(@"refresh fetched results controller");
    
//    [NSFetchedResultsController deleteCacheWithName:@"entriesCache"];
    fetchedResultsController = nil;
}

/**
 * Handles the fetchedResultsController used as source with tabel view
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    // Bad Idea to comment out!
    // But for sorting changes, fetchedResultsController cannot be cached the easy way.
    
    if (fetchedResultsController != nil) {
    
        return fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entry"
                                              inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    if ([[MayUserDefaults sharedInstance] listMarkedEntries]) {
        NSPredicate *predicate;
        predicate = [NSPredicate predicateWithFormat:@"isMarked = YES"];
        [request setPredicate:predicate];
    }
    
    [request setSortDescriptors:self.sortDescriptors];
    
    NSFetchedResultsController *resultsController;
    
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                            managedObjectContext:managedObjectContext
                                                              sectionNameKeyPath:nil
                                                                       cacheName:nil];
    resultsController.delegate = self;
    
    fetchedResultsController = resultsController;
    
    NSError *error = nil;
    
    if (![fetchedResultsController performFetch:&error]) {
        [App viewController:self
            handleUserError:error
                      title:@"Unresolved error"];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return fetchedResultsController;
}

/**
 * Handles content search and fills search results data structure.
 */
- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope {
    
    [_searchResults removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"authors CONTAINS[cd] %@ || title CONTAINS[cd] %@ || subtitle CONTAINS[cd] %@ || productCode CONTAINS[cd] %@ || publisher CONTAINS[cd] %@ || notes CONTAINS[cd] %@ || summary CONTAINS[cd] %@",
                              searchText, searchText, searchText, searchText, searchText, searchText, searchText];
    
    NSArray *entries = [self.fetchedResultsController fetchedObjects];
    
    [_searchResults removeAllObjects];

    if ([searchText isEqualToString:@""] || searchText == nil) {
        [_searchResults addObjectsFromArray:entries];
    }
    else {
        NSArray *filtered = [entries filteredArrayUsingPredicate:predicate];
        [_searchResults addObjectsFromArray:filtered];
    }
}

/**
 * Handles swipe action: sending mail with book entry
 */
- (void)sendMail:(NSManagedObject *)managedObject {
    
    NSMutableString *emailBody = [[NSMutableString alloc] init];
    
    Entry *entry = (Entry *)managedObject;
    
    NSString *emailSubject = [entry.title.unnil shortenToLength:80];
    
    [emailBody appendFormat:@"%@", [entry.authors.unnil stringByReplacingOccurrencesOfString:@"\n"
                                                                                  withString:@", "]];
    if (entry.publishing) {
        [emailBody appendFormat:@" (%@): ", entry.publishing.unnil];
    }
    else {
        [emailBody appendFormat:@" (%@): ", @"n.a."];
    }
    
    [emailBody appendFormat:@"%@.", entry.title.unnil.trimPuctuation];
    
    if (entry.subtitle) {
        [emailBody appendFormat:@" %@.", entry.subtitle.unnil.trimPuctuation];
    }
    
    if (entry.publisher) {
        [emailBody appendFormat:@" %@", entry.publisher.unnil];
    }
    
    if (entry.pageCount) {
        [emailBody appendFormat:@" %@pp.", entry.pageCount.unnil];
    }
    
    // where is the place?!
    
    [emailBody appendFormat:@" ISBN: %@.", entry.productCode.unnil];
    
    MFMailComposeViewController *mailComposerController = MFMailComposeViewController.new;
    
    if ([MFMailComposeViewController canSendMail]) {
        mailComposerController.mailComposeDelegate = self;
        
        // perhaps a setting...
        NSArray *emailRecipients = @[];
        mailComposerController.toRecipients = emailRecipients;
        mailComposerController.subject = emailSubject;
        
        [mailComposerController setMessageBody:emailBody
                                        isHTML:NO];
        
        [self presentViewController:mailComposerController
                           animated:YES
                         completion:nil];
        // new feature: Attachement with RIS file
        // Prequesits: Parsing of sure and lastname comming from service
        //        [mailComposerController addAttachmentData:[sampleData dataUsingEncoding:NSUTF8StringEncoding]
        //                                         mimeType:@"text/plain"
        //                                         fileName:risFileName];
    }
    else {
        [App viewConroller:self
                     title:NSLocalizedString(@"Mail error", nil)
                   message:NSLocalizedString(@"It's not possible to use mail", nil)];
    }
}

- (void)storeEntryWithISBN:(MayISBN *)isbn
                completion:(MayActionCompletionHandler)completion {
    
    NSError *error = nil;
    Entry *model = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                                 inManagedObjectContext:managedObjectContext];
    
    NSString *formattedIsbn = [MayISBNFormatter stringFromISBN:isbn];
    model.productCode = formattedIsbn;
    model.productCodeType = @(MayEntryCodeTypeISBN);
    model.referenceType = @(MayEntryTypeBook);
    model.isMarked = @([MayUserDefaults.sharedInstance listMarkedEntries]);
    
    [managedObjectContext save:&error];
    
    if (error) {
        completion(error);
        return;
    }
    
    // Trigger asynchronous service call to resolve the isbn to a full book description
    MayISBNGoogleResolver *resolver = MayISBNGoogleResolver.new;
    
    [resolver resolveWithISBN:isbn.isbnCode
                     complete:^(NSDictionary *result, NSError *error) {
                         
                         if (error) {
                             completion(error);
                             return;
                         }

                         NSDictionary *volumeInfo = [result objectForKey:@"volumeInfo"];
                         
                         NSArray  *authors = [volumeInfo objectForKey:@"authors"];
                         if (authors != nil) {
                             model.authors = [authors componentsJoinedByString:@"\n"];
                         }
                         model.title = [[volumeInfo objectForKey:@"title"] trimPuctuation];
                         model.subtitle = [[volumeInfo objectForKey:@"subtitle"] trimPuctuation];
                         
                         NSString *publishedDate = [volumeInfo objectForKey:@"publishedDate"];
                         
                         if (publishedDate.length > 4) {
                             model.publishing = [publishedDate substringToIndex:4];
                         }
                         else {
                             model.publishing = publishedDate;
                         }
                         
                         model.publisher = [volumeInfo objectForKey:@"publisher"];
                         model.pageCount = [[volumeInfo objectForKey:@"pageCount"] stringValue];
                         
                         NSString *printType = [volumeInfo objectForKey:@"printType"];

                         if ([printType isEqualToString:@"BOOK"]) {
                             model.referenceType = @(MayEntryTypeBookSection);
                         }
                         else {
                             // Default is BOOK.
                             model.referenceType = @(MayEntryTypeBookSection);
                         }
                         
                         model.productCodeType = @(MayEntryCodeTypeISBN);
                         model.language = [volumeInfo objectForKey:@"language"];
                         model.summary = [volumeInfo objectForKey:@"description"];
                         model.place = @"";
                         model.category = [volumeInfo objectForKey:@"mainCategory"];
                         
                         NSString *imageUrl = [[volumeInfo objectForKey:@"imageLinks"] objectForKey:@"thumbnail"];
                         
                         model.coverUrl = imageUrl;
                         
                         model.userFilename = nil;
                         
                         [managedObjectContext save:&error];
                         
                         completion(error);
                     }];
}

- (void)addISBNManualy {
    
    UIAlertController *actionAlert =
    [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ISBN", nil)
                                        message:NSLocalizedString(@"Input an ISBN-10 or ISBN-13 with or without seperation signs (-).", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];

    [actionAlert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.borderStyle = UITextBorderStyleNone;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.font = [UIFont systemFontOfSize:16.0];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.returnKeyType = UIReturnKeySend;
        textField.text = @"";
        [textField resignFirstResponder];
    }];

    [actionAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                      NSString *code = actionAlert.textFields[0].text;
                                                      NSError *error = nil;
                                                      MayISBN *isbn = [MayISBN ISBNFromString:code
                                                                                        error:&error];
                                                      if (error) {
                                                          return [App viewController:self
                                                                     handleUserError:(NSError *)error
                                                                               title:nil];
                                                      }
                                                      
                                                      [self storeEntryWithISBNAsyc:isbn];
                                                  }]];

    [actionAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];
    [self presentViewController:actionAlert
                       animated:YES
                     completion:nil];
}

- (void)storeEntryWithISBNAsyc:(MayISBN *)isbn {

    NSOperationQueue *operationQueue = [NSOperationQueue new];
    
    [operationQueue addOperationWithBlock:^{
        
        // Background work
        
        [self storeEntryWithISBN:isbn
                      completion:^(NSError *error) {

                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                              
                              // Main thread work (UI usually)
                              [App viewController:self
                                  handleUserError:error
                                            title:nil];

                              [self.tableView reloadData];
                          }];
        }];
    }];
}

/**
 * Changes state of marked bar button in lower toolbar
 */
- (void)listMarkedEntries:(BOOL)marked {
    
    if (marked) {
        _markBarButton.tintColor = [UIColor orangeColor];
        _markBarButton.image = [UIImage imageNamed:@"star-filled"];
    }
    else {
        _markBarButton.tintColor = self.view.tintColor;
        _markBarButton.image = [UIImage imageNamed:@"star"];
    }
}

@end
