//
//  ItemsController.m
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//
#import "AppDelegate.h"
#import "MayEntriesController.h"
#import "MayEntryCell.h"
#import "MayBarCodeScannerController.h"
#import "MayISBN.h"
#import "MayISBNFormatter.h"
#import "MayISBNGoogleResolver.h"
#import "Product.h"

@interface MayEntriesController()

@end

@implementation MayEntriesController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    managedObjectContext = ApplicationDelegate.managedObjectContext;
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
    
    Product *model =
    [fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell configureWithModel:model
                 atIndexPath:indexPath
                withDelegate:self];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 88;
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

- (void)deleteRecord:(MayEntryCell *)cell {
    
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

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        
        return fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest new];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product"
                                              inManagedObjectContext:managedObjectContext];
    
    [request setEntity:entity];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"productCode"
                                                                   ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [request setSortDescriptors:sortDescriptors];
    
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

#pragma mark - MAYBarCodeScannerDelegates

- (void)barCodeScannerController:(MayBarCodeScannerController *)controller
               didCaptureBarCode:(NSString *)barCode {

    // wenn barCode eine ISBN ist, dann wird jetzt eine Netzwerkafrage getriggert und das Ergebnis gespeichert und angezeigt.
    // Das wollen wir so machen:
    // 1) zunächst mal gucken, ob die ISBN schon gespeichert ist und nachfragen, ob ein neuer Datensatz angelegt werden soll, denn ISBNs werden manchmal doch für andere Auflagen verwendet, sodass es sich hier um ein zweites physikalisches Exemplar handeln kann. Eine Alternative wäre das Hochzählen eines Bestandscounters. Die Operation soll aber auch einfach abgebrochen werden, weil ein Buch irrtümlich (nocheinmal) hinzugefügt wurde.
    // 2) Das Produkt mit der ISBN sollte jetzt bereits gespeichert werden und die TableView aktualisiert.
    // 3) Solange aber noch keine Daten da sind, will ich das als User sehen und wissen, dass etwas passiert - Die Zellen, die Daten nachladen werden grau dargestellt, wenn die Daten da sind schwarz.
    // 4) Im Hintergrund wird eine Suche auf einem Service über die ISBN gemacht und bei erfolgreicher Suche wird der Datensatz vervollständigt. Natürlich könnte man Fragen, ob das das gesuchte Produkt das ist, dass man "eingescannt" hat. Diese Operation ist aber sehr lässtig.
    // 5) Während Netzwerkanfragen laufen will ich auf jeden Fall Details der bereits verfügbaren Daten im Detail sehen.
    // 6) Während Netzwerkabfragen laufen, könnte es cool sein, bereits in den Detail-Datensatz zu gehen. Hier sieht man natürlich nur eine ISBN und der Rest des Formulars ist "in progress" (wie auch immer das gut aussieht)
    
    // Andere Alternative
    // 1) Wenn der User einen BarCode gescannt hat, springt die Ansicht sofort in das Formular.
    // 2) Wenn keine Daten kommen, kann der User zumindest seinen Datensatz vervollständigen, wenn er das will. Oder den Datensatz einfach nicht speichern und kehrt zurück in die Produktliste.
    
    
    NSError *error = nil;
    
    MayISBN *isbn = [MayISBN ISBNFromString:barCode
                                      error:&error];
    if (error != nil) {
        
        // handle error with a message to the user...
    }
    
    Product *model = [NSEntityDescription insertNewObjectForEntityForName:@"Product"
                                                   inManagedObjectContext:managedObjectContext];
    
    NSString *formattedIsbn = [MayISBNFormatter stringFromISBN:isbn];
    model.productCode = formattedIsbn;
    model.productCodeType = @(MayProductCodeTypeISBN);
    model.productType = @(MayProductTypeBook);

//    if (![managedObjectContext save:&error]) {
//
//        NSLog(@"Unresolved error %@, %@", error, [error localizedDescription]);
//    }
//    
//    [self.tableView reloadData];
    
    MayISBNGoogleResolver *resolver = [MayISBNGoogleResolver new];
    [resolver resolveWithISBN:isbn.isbnCode complete:^(NSDictionary *result, NSError *error) {

        NSDictionary *volumeInfo = [result objectForKey:@"volumeInfo"];
        
//        NSLog(@"%@", volumeInfo);
        
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

        if (![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error localizedDescription]);
        }
        
        [self.tableView reloadData];
        
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"openScanner"]) {
        
        MayBarCodeScannerController *controller =
        (MayBarCodeScannerController *)segue.destinationViewController;
        controller.delegate = self;
        // options...
    }
}

@end
