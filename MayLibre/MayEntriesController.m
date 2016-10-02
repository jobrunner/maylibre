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
#import "MayTableViewOptionsBag.h"
#import "MaySearchController.h"


@interface MayEntriesController() {

    NSManagedObjectContext *managedObjectContext;
}

typedef void (^MayActionCompletionHandler)(NSError *error);

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *markBarButton;

- (IBAction)scanBarButtonSelected:(UIBarButtonItem *)sender;
- (IBAction)actionBarButtonSelected:(UIBarButtonItem *)sender;
- (IBAction)markBarButtonSelected:(UIBarButtonItem *)sender;

@end

@implementation MayEntriesController

#pragma mark UIViewControllerDelegates

- (void)viewDidLoad {

    [super viewDidLoad];

    managedObjectContext = App.managedObjectContext;
    
    [self configureSearch];
    [self hideSearchBarAnimated:YES];

    [self showOptionsBarButton];
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

    self.definesPresentationContext = YES;

    if ([segue.identifier isEqualToString:@"openScannerSegue"]) {
        
        MayBarCodeScannerController *controller =
        (MayBarCodeScannerController *)segue.destinationViewController;
        controller.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"openEntryDetailsSegue"]) {
        
        MayEntryDetailsController *controller =
        (MayEntryDetailsController *)segue.destinationViewController;
        
        MayEntryCell *cell = sender;
        Entry *model = [self.fetchedResultsControllerForContext objectAtIndexPath:cell.indexPath];
        
        controller.entry = model;
    }
    
    if ([segue.identifier isEqualToString:@"openEntryFormSegue"]) {
        
        MayEntryFormController *controller =
        (MayEntryFormController *)segue.destinationViewController;
        
        MayEntryCell *cell = sender;
        Entry *model = [self.fetchedResultsControllerForContext objectAtIndexPath:cell.indexPath];
        
        controller.entry = model;
    }
    
    if ([segue.identifier isEqualToString:@"tableViewOptionsSegue"]) {
        
        self.definesPresentationContext = NO;

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
    
    [self resetFetchedResultsControllerForContext];
    [self.tableView reloadData];
}

#pragma mark UISearchControllerDelegate

- (void)didPresentSearchController:(UISearchController *)searchController {

    [self resetFetchedResultsController];
}

- (void)didDismissSearchController:(UISearchController *)searchController {

    [self resetSearchFetchedResultsController];
}

#pragma mark  UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(MayEntryCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Entry *model = [self.fetchedResultsControllerForContext objectAtIndexPath:indexPath];

//    NSManagedObject *model = [self.fetchedResultsControllerForContext objectAtIndexPath:indexPath];

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

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
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
    
    return [self.fetchedResultsControllerForContext.sections objectAtIndex:section].numberOfObjects;
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
    
    return self.fetchedResultsControllerForContext.sections.count;
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

//- (NSInteger)tableView:(UITableView *)tableView
//sectionForSectionIndexTitle:(NSString *)title
//               atIndex:(NSInteger)index {
//    
//    if (self.searchController.active) {
//        
//        return 0;
//    }
//    
//    if (index > 0) {
//        // The index is offset by one to allow for the extra search icon inserted at the front of the index
//        return [self.fetchedResultsController sectionForSectionIndexTitle:title
//                                                                  atIndex:(index - 1)];
//    }
//    else {
//        // The first entry in the index is for the search icon so we return section not found and force the table to scroll to the top.
//        CGRect searchBarFrame = self.searchController.searchBar.frame;
//        
//        [self.tableView scrollRectToVisible:searchBarFrame
//                                   animated:NO];
//        
//        return NSNotFound;
//    }
//}

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
        [self sendMail:[self.fetchedResultsControllerForContext objectAtIndexPath:cell.indexPath]];
    }
    
    return YES;
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
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

    switch(type) {
        case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
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

    MayTableViewOptionsTransitionAnimator *animator;
    
    animator = [MayTableViewOptionsTransitionAnimator new];
    animator.presenting = YES;
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

    MayTableViewOptionsTransitionAnimator *animator;
    
    animator = [MayTableViewOptionsTransitionAnimator new];
    animator.presenting = NO;

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

    NSInteger optionKey = [[sortOption objectForKey:MayTableViewOptionsBagItemKeyKey] integerValue];
    
    [[MayTableViewOptionsBag sharedInstance] setActiveSortOptionKey:optionKey
                                                          forEntity:@"Entry"];
    [self resetFetchedResultsControllerForContext];
    [self.tableView reloadData];
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
    
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    actionSheet.popoverPresentationController.barButtonItem = sender;
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

- (IBAction)markBarButtonSelected:(UIBarButtonItem *)sender {

    [self listMarkedEntries:[MayUserDefaults.sharedInstance toogleListMarkedEntries]];
    
    [self resetFetchedResultsControllerForContext];
    
    [self.tableView reloadData];
}

#pragma mark MayEntriesController

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
        
        NSManagedObjectContext *context = [self.fetchedResultsControllerForContext managedObjectContext];

        NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];

        [context deleteObject:[self.fetchedResultsControllerForContext objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        
        if (![context save:&error]) {

            [App viewController:self
                handleUserError:error
                          title:nil];
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

    NSManagedObjectContext *context = [self.fetchedResultsControllerForContext managedObjectContext];
    
    Entry *entry = [self.fetchedResultsControllerForContext objectAtIndexPath:indexPath];
    
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
    
//    NSString *sortField = [[MayUserDefaults sharedInstance] sortFieldForEntity:@"entry"];
//    BOOL ascending = [[MayUserDefaults sharedInstance] sortAscendingForEntity:@"entry"];
    
    NSDictionary *sortOption = [[MayTableViewOptionsBag sharedInstance] activeSortOption:@"Entry"];
    
    NSString *sortField = [sortOption objectForKey:MayTableViewOptionsBagItemFieldKey];
    BOOL ascending = [[sortOption objectForKey:MayTableViewOptionsBagItemAscendingKey] boolValue];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField
                                                                   ascending:ascending];
    return @[sortDescriptor];
}

/**
 * Destroys fetchedResultsController for renewing
 */
- (void)resetFetchedResultsController {
    
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
}

/**
 * Destroys searchFetchedResultsController for renewing
 */
- (void)resetSearchFetchedResultsController {
    
    _searchFetchedResultsController.delegate = nil;
    _searchFetchedResultsController = nil;
}

/**
 * Destroys the active NSFetchedResultsController for renewing
 */
- (void)resetFetchedResultsControllerForContext {
    
    if (self.searchController.active) {

        [self resetSearchFetchedResultsController];
    }
    else {
    
        [self resetFetchedResultsController];
    }
}

/**
 * Returns a fetchedResultsController for current context (table view or search view)
 */
- (NSFetchedResultsController *)fetchedResultsControllerForContext {
    
    if (self.searchController.active) {
        
        return self.searchFetchedResultsController;
    }
    
    return self.fetchedResultsController;
}

/**
 * Overrides fetchedResultsController getter
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        
        return _fetchedResultsController;
    }

    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    
    return _fetchedResultsController;
}

/**
 * Overrides searchResultsController getter
 */
- (NSFetchedResultsController *)searchFetchedResultsController {

    if (_searchFetchedResultsController != nil) {
        
        return _searchFetchedResultsController;
    }

    NSString *searchText = self.searchController.searchBar.text;
    
    _searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:searchText];
    
    return _searchFetchedResultsController;
}

/**
 * Create a fetched result controller upon search and/or other predicates
 */
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchText {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entry"
                                              inManagedObjectContext:managedObjectContext];

    NSMutableArray *predicates = [NSMutableArray new];

    if ([[MayUserDefaults sharedInstance] listMarkedEntries]) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isMarked = YES"];
        [predicates addObject:predicate];
    }

    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"authors CONTAINS[cd] %@ || title CONTAINS[cd] %@ || subtitle CONTAINS[cd] %@ || productCode CONTAINS[cd] %@ || publisher CONTAINS[cd] %@ || notes CONTAINS[cd] %@ || summary CONTAINS[cd] %@",
                                  searchText, searchText, searchText, searchText, searchText, searchText, searchText];
        [predicates addObject:predicate];
    }
    
    NSPredicate *predicate = nil;
    
    if (predicates.count > 0) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    }
    
    NSFetchRequest *request = NSFetchRequest.new;
    request.entity = entity;
    request.predicate = predicate;
    request.fetchBatchSize = 20;
    request.sortDescriptors = self.sortDescriptors;
    
    NSFetchedResultsController *resultsController;
    
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                            managedObjectContext:managedObjectContext
                                                              sectionNameKeyPath:nil
                                                                       cacheName:nil];
    resultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![resultsController performFetch:&error]) {
        [App viewController:self
            handleUserError:error
                      title:@"Unresolved error"];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
  
    return resultsController;
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
