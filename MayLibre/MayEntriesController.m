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

#import "Store.h"
#import "FetchedResultsControllerDataSource.h"

@interface MayEntriesController()
//{
//
//    NSManagedObjectContext *managedObjectContext;
//}

typedef void (^MayActionCompletionHandler)(NSError *error);

//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) FetchedResultsControllerDataSource* fetchedResultsControllerDataSource;
@property (nonatomic, strong) FetchedResultsControllerDataSource* searchFetchedResultsControllerDataSource;

// die nicht mehr direkt verwalten, das übernehmen Instanzen von FetchedResultsControllerDataSource
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

//    Store *store = App.store;
//    self.managedObjectContext = store.managedObjectContext;
    
    // setup fetchedResultsController for table view
    
    self.fetchedResultsControllerDataSource =
    [[FetchedResultsControllerDataSource alloc] initWithTableView:self.tableView];

    self.fetchedResultsControllerDataSource.reuseIdentifier = @"MayEntryCell";
    self.fetchedResultsControllerDataSource.nibName = @"MayEntryCell";
    self.fetchedResultsControllerDataSource.delegate = self;

    // setup searchFtchedResultsController for search table view
//    self.searchFetchedResultsControllerDataSource =
//    [[FetchedResultsControllerDataSource alloc] initWithTableView:self.tableView];
//    
//    self.searchFetchedResultsControllerDataSource.reuseIdentifier = @"MayEntryCell";
//    self.searchFetchedResultsControllerDataSource.nibName = @"MayEntryCell";
//    self.searchFetchedResultsControllerDataSource.delegate = self;
    
    
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

    [self.fetchedResultsControllerDataSource refresh];
    [self.tableView reloadData];
}

#pragma mark UISearchControllerDelegate

- (void)didPresentSearchController:(UISearchController *)searchController {
    
    [self.fetchedResultsControllerDataSource refresh];
}

- (void)didDismissSearchController:(UISearchController *)searchController {

    [self.searchFetchedResultsControllerDataSource refresh];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Entry *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [((MayEntryCell *)cell) configureWithModel:model
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
    [self resetFetchedResultsController];
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

    [self resetFetchedResultsController];
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
        
        NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
        NSManagedObject *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [App.store deleteObject:model];
        
        NSError *error = nil;

        if (![App.store save:&error]) {
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
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];

    Entry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // toogle isMarked flag
    entry.isMarked = ([entry.isMarked boolValue]) ? @NO : @YES;
    
    NSError *error = nil;

    if (![App.store save:&error]) {
        [App viewController:self
            handleUserError:error
                      title:nil];
        
    }
}

/**
 * Builds sort descriptors for table view.
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
 * Destroys the active NSFetchedResultsController for renewing
 */
- (void)resetFetchedResultsController {

    [self.fetchedResultsControllerDataSource refresh];
}

/**
 * Returns a fetchedResultsController for current context (table view or search view)
 */
- (NSFetchedResultsController *)fetchedResultsController {

    return self.fetchedResultsControllerDataSource.fetchedResultsController;
}

/**
 * Create a fetchedResultsController instance upon search and/or other predicates
 */
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchText {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entry"
                                              inManagedObjectContext:App.store.managedObjectContext];

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
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = entity;
    request.predicate = predicate;
    request.fetchBatchSize = 20;
    request.sortDescriptors = self.sortDescriptors;
    
    NSFetchedResultsController *resultsController;
    
    resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                            managedObjectContext:App.store.managedObjectContext
                                                              sectionNameKeyPath:nil
                                                                       cacheName:nil];
    // set to nil delegates the setting of the delegates to the caller
    resultsController.delegate = nil;
    
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
 * Constucting fetchedResultsController that will be used by FetchedResultsControllerDataSource
 */
- (NSFetchedResultsController *)fetchedResultsControllerDataSource:(FetchedResultsControllerDataSource *)fetchedResultsControllerDataSource {
    
    if (self.searchController.active) {
        
        NSString *searchText = self.searchController.searchBar.text;
        
        return [self newFetchedResultsControllerWithSearch:searchText];
    }
    
    return [self newFetchedResultsControllerWithSearch:nil];
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

    Entry *model = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                                 inManagedObjectContext:App.store.managedObjectContext];
    
    NSString *formattedIsbn = [MayISBNFormatter stringFromISBN:isbn];

    model.productCode     = formattedIsbn;
    model.productCodeType = @(MayEntryCodeTypeISBN);
    model.referenceType   = @(MayEntryTypeBook);
    model.isMarked        = @([MayUserDefaults.sharedInstance listMarkedEntries]);
    
    NSError *error = nil;
    
    [App.store save:&error];
    
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
                         
                         [App.store save:&error];
                         
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
