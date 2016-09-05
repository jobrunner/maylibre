//
//  MayEntryFormController.m
//  MayLibre
//
//  Created by Jo Brunner on 26.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "AppDelegate.h"
#import "MayEntryFormController.h"
#import "MayEntrySummaryFormController.h"
#import "MayImageManager.h"
#import "MayEntrySummaryFormCell.h"
#import "MayUserDefaults.h"
#import "MayDigest.h"

@implementation MayEntryFormController

#pragma mark UIViewControllerDelegates

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
    
    self.tableView.estimatedRowHeight = 44;
    
    self.authorsTextView.delegate = self;
    
    managedObjectContext = ApplicationDelegate.managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeSummary:)
                                                 name:kNotificationEntrySummaryChanged
                                               object:nil];
    if (_entry == nil) {
        [self createModelForEditing];
    }
    else {
        [self loadModelForUpdate];
    }
}

#pragma mark UITableViewDelegates

/**
 * Although we need static cells here the tableView must know
 * automatic height otherwise it uses the costum height set
 * in Interface Builder.
 */
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
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

#pragma mark MayEntryFormController

- (void)loadModelForUpdate {
    
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Save", nil);
    self.navigationItem.rightBarButtonItem.enabled = false;

    _authorsTextView.text = _entry.authors;
    _titleTextField.text = _entry.title;
    _subtitleTextField.text = _entry.subtitle;
    _yearTextField.text = _entry.publishing;
    _publisherTextField.text = _entry.publisher;
    _pagesTextField.text = _entry.pageCount;
    _isbnTextField.text = _entry.productCode;
    _placeTextField.text = _entry.place;
    _summaryLabel.text = _entry.summary;
    
    NSLog(@"Alternative Cover: %@", _entry.userFilename);
    
    
    // wenn userFilename einen Wert hat, soll zunächst ein thumbnail dazu geladen werden.
    // Wenn das Thumbnail in diesem Cache nicht existiert, soll es erzeugt und geladen werden
    // Das Original-Foto soll weiterhin im Dokumentenverzeichnis/Pictures liegen und später auf die
    // iCloude synchronisiert werden. Die Thumbnails nicht. Auch nicht die Bilder aus dem Web (Copyrights
    // und Speicher etc. - die gehören Google bzw. Amazon).
    
    if (_entry.userFilename != nil) {

        // Zum Testen das Original Foto laden und anzeigen
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Pictures"];
        
        // create the full file path
        NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", _entry.userFilename]];

        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        NSLog(@"File: %@", filePath);
        UIImage *image = [UIImage imageWithData:imageData];
        _bookImage.image = image;
        
        return;
        
        
        
//        if (imageData.length > 0) {
//            UIImage *image = [UIImage imageWithData:imageData];
//            _bookImage.image = image;
//
//            return;
//        }
        
    }
    
    [[MayImageManager sharedManager] imageWithUrlString:_entry.coverUrl
                                             completion:^(UIImage *image, NSError *error) {
                                                 if (error) {
                                                     NSLog(@"Error while assigning image: %@",
                                                           error.localizedDescription);
                                                 }
                                                 _bookImage.image = image;
                                             }];
}

- (void)createModelForEditing {
    
    _entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                           inManagedObjectContext:managedObjectContext];
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Create", nil);
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    _authorsTextView.text = _entry.authors;
    _titleTextField.text = _entry.title;
    _subtitleTextField.text = _entry.subtitle;
    _yearTextField.text = _entry.publishing;
    _publisherTextField.text = _entry.publisher;
    _pagesTextField.text = _entry.pageCount;
    _isbnTextField.text = _entry.productCode;
    _placeTextField.text = _entry.place;
    _summaryLabel.text = _entry.summary;
}

- (void)saveForm {
    
    _entry.authors = _authorsTextView.text;
    _entry.title = _titleTextField.text;
    _entry.subtitle = _subtitleTextField.text;
    _entry.publishing = _yearTextField.text;
    _entry.place = _placeTextField.text;
    _entry.pageCount = _pagesTextField.text;
    _entry.productCode = _isbnTextField.text;
    _entry.publisher = _publisherTextField.text;
    _entry.summary = _summaryLabel.text;
    _entry.isMarked = @([MayUserDefaults.sharedInstance listMarkedEntries]);
    
    NSError *error = nil;
    
    [managedObjectContext save:&error];
    
    if (error) {
        [App viewController:self
            handleUserError:error
                      title:nil];
    }
}

- (void)undoForm {
    
    [managedObjectContext rollback];
}

- (void)changeSummary:(NSNotification *)notification {
    
    _entry.summary = (NSString *)notification.object;
    _summaryLabel.text = _entry.summary;

    [self refreshTableViewCellAutolayout];
    [self formDidChanged:_summaryLabel];
}

- (void)refreshTableViewCellAutolayout {
    
    CGPoint currentOffset = [self.tableView contentOffset];
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    [self.tableView setContentOffset:currentOffset
                            animated:NO];
}

#pragma mark - Helper

- (void)formDidChanged:(id)sender {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)goToPreviousViewController {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark UITextViewDelegates

- (void)textViewDidChange:(UITextView *)textView {
    
    [self refreshTableViewCellAutolayout];
    [self formDidChanged:textView];
}

#pragma mark IBActions

- (IBAction)updateButtonSelected:(UIBarButtonItem *)sender {
    
    [self saveForm];
    [self goToPreviousViewController];
}

- (IBAction)cancelButtonSelected:(UIBarButtonItem *)sender {

    [self undoForm];
    [self goToPreviousViewController];
}

- (IBAction)titleTextFieldChanged:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)subtitleTextFieldChanged:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)yearTextFieldChanged:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)publisherTextFieldChanged:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)pagesTextFieldChanged:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)isbnTextFieldChanged:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)placeTextFieldChanged:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (void)removeCurrentCover {
    
    UIAlertController *actionSheet =
    [UIAlertController alertControllerWithTitle:nil // NSLocalizedString(@"", nil)
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *removeCoverAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove Cover", nil)
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {
                               
                               [[MayImageManager sharedManager] removeUserFile:_entry.userFilename
                                                                    completion:^(NSError *error) {
                                                                    
                                                                        if (error == nil) {
                                                                            _entry.userFilename = nil;
                                                                            [managedObjectContext save:&error];
                                                                        }
                                                                        
                                                                        if (error) {
                                                                            [App viewController:self
                                                                                handleUserError:error
                                                                                          title:nil];
                                                                        }
                                                                        
                                                                    }];
                           }];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [actionSheet addAction:removeCoverAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
    
}

- (void)replaceCurrentCover {
    
    UIAlertController *actionSheet =
    [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Replace Cover", nil)
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *lastPhotoTakenAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Last Photo Taken", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {

                               NSLog(@"Last Photo Taken aus Gallary holen, speichern und UI refresh");
                               
                           }];
    
    UIAlertAction *takePhotoAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {

                               NSLog(@"Take Photo, speichern und UI refresh");

                           }];
    
    UIAlertAction *chooseFromLibraryAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Library", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {

                               [self takeCoverFromLibrary];
                               
                               NSLog(@"Choose from Library, speichern und UI refresh");
                           
                           }];
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [actionSheet addAction:lastPhotoTakenAction];
    [actionSheet addAction:takePhotoAction];
    [actionSheet addAction:chooseFromLibraryAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
    
}

- (IBAction)changeCoverImage:(UIButton *)sender {
    
// Wenn noch kein Cover vorhanden ist:
    // Last Photo Taken
    // Take Photo
    // Choose from Library
    // ---
    // Cancel
    
// Wenn bereits ein Cover vorhanden ist:
    // Remove Photo
    // ---
    // Cancel
    
    if (_entry.coverUrl != nil || _entry.userFilename != nil) {
        
        // remove photo
        [self removeCurrentCover];
    }
    else {
        [self replaceCurrentCover];
    }
}

- (void)takeCoverFromLibrary {
    
    UIImagePickerController *picker = [UIImagePickerController new];
    
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker
                       animated:YES
                     completion:NULL];
}

- (void)takePhoto {
    
    UIImagePickerController *picker = [UIImagePickerController new];

    picker.delegate = self;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.showsCameraControls = YES;
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:picker
                       animated:YES
                     completion:NULL];
}

#pragma mark - UIImagePickerController Delegates -

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [[MayImageManager sharedManager] storeImage:chosenImage
                                     completion:^(NSString *filename, NSError *error) {
                                         
                                         NSLog(@"filename: %@", filename);
                                         
                                         if (error == nil) {
                                             _entry.userFilename = filename;
                                             [managedObjectContext save:&error];
                                         }
                                         if (error) {
                                             [App viewController:self
                                                 handleUserError:error
                                                           title:nil];
                                         }
                                         
                                     }];

    [picker dismissViewControllerAnimated:YES
                               completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES
                               completion:NULL];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"openEntrySummaryEditSegue"]) {
        MayEntrySummaryFormController * controller = segue.destinationViewController;
        controller.entry = _entry;
    }
}

@end
