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
#import "MayEntryCell.h"
#import "MayBarCodeScannerController.h"
#import "MayISBN.h"
#import "MayISBNFormatter.h"
#import "MayISBNGoogleResolver.h"
#import "MayDigest.h"
#import "Entry.h"
#import "MayImageManager.h"
#import "NSString+MayDisplayExtension.h"

@interface MayEntriesController()

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegmentationControl;

- (IBAction)scanBarButton:(UIBarButtonItem *)sender;
- (IBAction)sortSegmentationValueChanged:(UISegmentedControl *)sender;

@end

@implementation MayEntriesController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    managedObjectContext = ApplicationDelegate.managedObjectContext;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.navigationController setToolbarHidden:NO
                                       animated:YES];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

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

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(MayEntryCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Entry *model =
    [fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell configureWithModel:model
                 atIndexPath:indexPath
                withDelegate:self];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 80; // @todo: check autolayout height in xib file!
    return UITableViewAutomaticDimension;
}

//- (void)tableView:(UITableView *)tableView
//didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    // select entry for detail, editing or deletion...
//}

// Dosn't support native editing of table view cells.
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

// Dosn't support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MayEntryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"openEntryFormSegue"
                              sender:cell];
}

- (BOOL)swipeTableCell:(MayEntryCell *)cell
   tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction
         fromExpansion:(BOOL)fromExpansion {
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        
        [self deleteRecordFromCell:cell];
        
        return NO;
    }
    
//    if (direction == MGSwipeDirectionRightToLeft && index == 1) {
//        
//        [self toggleMarkFromCell:cell];
//    }
    
    if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        // Send an email with sample data
        [self sendMail:[self.fetchedResultsController objectAtIndexPath:cell.indexPath]];
    }
    
    return YES;
}


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
                                            style:UIAlertActionStyleDefault
                                          handler:nil];
    [actionSheet addAction:deleteAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

- (void)toggleMarkFromCell:(UITableViewCell *)cell {
    
    // Mark sample
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    Entry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // toogle isMarked flag
     entry.isMarked = ([entry.isMarked boolValue]) ? @NO : @YES;
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error localizedDescription]);
    }
}

#pragma mark - NSFetchedResultsController Delegate and Helpers

- (NSArray *)sortDescriptors {

    static NSArray *sortKeysBySegmentation = nil;
    
    if (sortKeysBySegmentation == nil) {
        sortKeysBySegmentation = @[@"authors", @"title", @"creationTime"];
    }

    NSString *sortKey =
    [sortKeysBySegmentation objectAtIndex:_sortSegmentationControl.selectedSegmentIndex];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey
                                                                   ascending:NO];
    NSLog(@"Sorting: %@", sortKey);
    return @[sortDescriptor];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
// Bad Idea to comment out!
// But for sorting changes, fetchedResultsController cannot be cached the easy way.
    
//    if (fetchedResultsController != nil) {
//        
//        return fetchedResultsController;
//    }
    
    NSFetchRequest *request = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entry"
                                              inManagedObjectContext:managedObjectContext];
    
    [request setEntity:entity];
    
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
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return fetchedResultsController;
}

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
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark Mail Composer Delegates

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)sendMail:(NSManagedObject *)managedObject {
    
    NSMutableString *emailBody = [[NSMutableString alloc] init];
    
    Entry *entry = (Entry *)managedObject;

    NSString *emailSubject = [entry.title.unnil shortenToLength:80];
    
    [emailBody appendFormat:@"%@", [entry.authors.unnil stringByReplacingOccurrencesOfString:@"\n"
                                                                                  withString:@", "]];
    if (entry.publishedDate) {
        [emailBody appendFormat:@" (%@): ", entry.publishedDate.unnil];
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
    
    NSArray *emailRecipients = @[];
    
    MFMailComposeViewController *mailComposerController = [[MFMailComposeViewController alloc]init];
    
    if ([MFMailComposeViewController canSendMail]) {
        mailComposerController.mailComposeDelegate = self;
        
        mailComposerController.toRecipients = emailRecipients;
        mailComposerController.subject = emailSubject;
        
        [mailComposerController setMessageBody:emailBody
                                        isHTML:NO];
        
        [self presentViewController:mailComposerController
                           animated:YES
                         completion:nil];
        
//        [mailComposerController addAttachmentData:[sampleData dataUsingEncoding:NSUTF8StringEncoding]
//                                         mimeType:@"text/plain"
//                                         fileName:risFileName];
    }
    else {
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Mail error", nil)
                                            message:NSLocalizedString(@"It's not possible to use mail", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction;
        alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                               style:UIAlertActionStyleDefault
                                             handler:nil];
        [alertController addAction:alertAction];
        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - Helper

- (void)handleInvalidISBN:(NSString *)barCode withError:(NSError *)error {

    // gescanntes Ding ist zwar ein BarCode, aber kein Buch (oder die ISBN ist sonst falsch).
    // Retry, Cancel, manuelle Eingabe
    

    
    // Fehler anzeigen und ggf. die manuelle Eingabe einer ISBN ermöglichen.
    
    void (^retryActionHandler)() = ^{
        // hierfür brauche ich eine Instanz vom MayBarCodeScannerController...
        // [_session startRunning];
    };
    
    // close scanner without storing entry
    void (^cancelActionHandler)() = ^{
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ISBN invalid", nil)
                                                      message:error.localizedDescription
                                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *retryAction;
    retryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil)
                                           style:UIAlertActionStyleDefault
                                         handler:retryActionHandler];
    
//    UIAlertAction *applyAction;
//    applyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Apply", nil)
//                                           style:UIAlertActionStyleDefault
//                                         handler:applyActionHandler];

    UIAlertAction *cancelAction;
    cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                            style:UIAlertActionStyleDestructive
                                          handler:cancelActionHandler];
    
    [actionSheet addAction:cancelAction];
//    [actionSheet addAction:retryAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

- (void)storeEntryWithISBN:(MayISBN *)isbn
                     error:(NSError **)error {

    Entry *model = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                                 inManagedObjectContext:managedObjectContext];
    
    NSString *formattedIsbn = [MayISBNFormatter stringFromISBN:isbn];
    model.productCode = formattedIsbn;
    model.productCodeType = @(MayEntryCodeTypeISBN);
    model.productType = @(MayEntryTypeBook);
    
    if (![managedObjectContext save:error]) {
        
        // Error Message to the User: Could not save...
        NSLog(@"Unresolved error %@", (*error).localizedDescription);
        return;
    }
    
    // Trigger asynchronous service call to resolve the isbn to a full book description
    MayISBNGoogleResolver *resolver = MayISBNGoogleResolver.new;
    
    [resolver resolveWithISBN:isbn.isbnCode
                     complete:^(NSDictionary *result, NSError *error) {
        
                         if (error) {
                             NSLog(@"Error while resolving ISBN: %@", error.localizedDescription);
                             return;
                         }
                         
                         NSDictionary *volumeInfo = [result objectForKey:@"volumeInfo"];
        
                         NSArray  *authors = [volumeInfo objectForKey:@"authors"];
                         if (authors != nil) {
                             model.authors = [authors componentsJoinedByString:@"\n"];
                         }
                         model.title = [volumeInfo objectForKey:@"title"];
                         model.subtitle = [volumeInfo objectForKey:@"subtitle"];
                         model.publishedDate = [volumeInfo objectForKey:@"publishedDate"];
                         model.publisher = [volumeInfo objectForKey:@"publisher"];
                         model.pageCount = [[volumeInfo objectForKey:@"pageCount"] stringValue];
                         model.printType = [volumeInfo objectForKey:@"printType"];
                         model.language = [volumeInfo objectForKey:@"language"];
        
                         NSString *imageUrl = [[volumeInfo objectForKey:@"imageLinks"] objectForKey:@"thumbnail"];

                         model.coverUrl = imageUrl;
                         
                         if (![managedObjectContext save:&error]) {

                             // completion handler mit error aufrufen
                             NSLog(@"Error while storing Resolved ISBN Data: %@", error.localizedDescription);
            
                             return;
                         }
    }];
    error = nil;
}

#pragma mark - MAYBarCodeScannerDelegates

- (void)barCodeScannerController:(MayBarCodeScannerController *)controller
                  didCaptureISBN:(MayISBN *)isbn {

    NSOperationQueue *operationQueue = [NSOperationQueue new];
    
    [operationQueue addOperationWithBlock:^{
        
        // Background work

        NSError *error = nil;

        [self storeEntryWithISBN:isbn
                           error:&error];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            // Main thread work (UI usually)
            [self.tableView reloadData];
        }];
    }];
}

#pragma mark IBActions

- (IBAction)scanBarButton:(UIBarButtonItem *)sender {
    
    [self performSegueWithIdentifier:@"openScanner" sender:sender];
}

- (IBAction)sortSegmentationValueChanged:(UISegmentedControl *)sender {
    
    NSLog(@"segmented changed to: %ld", (long)sender.selectedSegmentIndex);
    
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"openScannerSegue"]) {
        
        MayBarCodeScannerController *controller =
        (MayBarCodeScannerController *)segue.destinationViewController;
        controller.delegate = self;
        // options...
    }
    
    if ([segue.identifier isEqualToString:@"openEntryFormSegue"]) {

        MayEntryFormController *controller =
        (MayEntryFormController *)segue.destinationViewController;

        MayEntryCell *cell = sender;
        Entry *model = [self.fetchedResultsController objectAtIndexPath:cell.indexPath];
        
        controller.entry = model;
    }
}

@end
