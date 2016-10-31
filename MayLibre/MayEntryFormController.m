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
#import "Store.h"
#import "MayImagePickerController.h"
#import "MayImageCropperController.h"

@implementation MayEntryFormController

#pragma mark UIViewControllerDelegates

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
    
    self.tableView.estimatedRowHeight = 44;

    self.authorsTextView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeSummary:)
                                                 name:kNotificationEntrySummaryChanged
                                               object:nil];
    
    UITapGestureRecognizer *coverImageTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleCoverTap:)];
    [self.bookImage addGestureRecognizer:coverImageTap];
    
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
    
    [self loadCoverImageWithEntry:_entry
                       completion:^(UIImage *image, NSError *error) {
                           _bookImage.image = image;
                       }];
    
}

- (void)loadCoverImageWithEntry:(Entry *)entry
                     completion:(void(^)(UIImage *image, NSError *error))completion {

    MayImageManager *imageManager = [MayImageManager sharedManager];;
    
    if (entry.userFilename != nil) {
        
        completion([imageManager imageWithFilename:_entry.userFilename], nil);
        
        return;
    }
    
    [imageManager imageWithUrlString:_entry.coverUrl
                          completion:^(UIImage *image, NSError *error) {
                              
                              completion(image, error);
                          }];
}


- (void)createModelForEditing {
    
    _entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                           inManagedObjectContext:App.store.managedObjectContext];
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
    
    if (![App.store save:&error]) {
        [App viewController:self
            handleUserError:error
                      title:nil];
    }
}

- (void)undoForm {
    
    [App.store.managedObjectContext rollback];
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

- (void)handleCoverTap:(UITapGestureRecognizer *)recognizer {
    
    [self changeCoverImage:_changeCoverButton];
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

- (void)replaceCurrentCover:(UIButton *)sender {
    
    __weak typeof(self)weakSelf = self;
    
    UIAlertController *actionSheet =
    [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Replace Cover", nil)
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *lastPhotoTakenAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Last Photo Taken", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {

                               [weakSelf takeCoverFromLastTakenLibraryImage];
                           }];
    
    UIAlertAction *takePhotoAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {

                               [weakSelf takeCoverFromCamera];
                           }];
    
    UIAlertAction *chooseFromLibraryAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Library", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {

                               [weakSelf takeCoverFromLibrary];
                           }];

    UIAlertAction *removeCoverAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove Cover", nil)
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {

                               [weakSelf removeCoverImage];
                           }];

    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    [actionSheet addAction:lastPhotoTakenAction];
    [actionSheet addAction:takePhotoAction];
    [actionSheet addAction:chooseFromLibraryAction];
    
    // initial coverUrl cannot be removed. But user cover only
    if (_entry.userFilename != nil) {
        [actionSheet addAction:removeCoverAction];
    }
    
    [actionSheet addAction:cancelAction];

    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    actionSheet.popoverPresentationController.sourceView = sender;
    actionSheet.popoverPresentationController.sourceRect = sender.bounds;
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
    
}

- (IBAction)changeCoverImage:(UIButton *)sender {
 
    [self replaceCurrentCover:sender];
}

- (void)takeCoverFromLibrary {

    MayImagePickerController *picker = [MayImagePickerController new];
    
    picker.delegate = self;
    picker.sourceType = SourceTypeLibrary;
    
    [self presentViewController:picker
                       animated:NO
                     completion:nil];
}

- (void)takeCoverFromLastTakenLibraryImage {

    [MayImagePickerController lastTakenImageFromLibrary:^(UIImage *image, NSDictionary *dict) {
    
        MayImageCropperController *picker =
        [[MayImageCropperController alloc] initWithOriginalImage:image];
    
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationPopover;
    
        [self presentViewController:picker
                           animated:YES
                         completion:nil];
        }];
}

- (void)takeCoverFromCamera {

    MayImagePickerController *picker = [MayImagePickerController new];
    
    picker.delegate = self;
    picker.sourceType = SourceTypeCamera;
    
    [self presentViewController:picker
                       animated:NO
                     completion:nil];
}

- (void)removeCoverImage {
    
    [[MayImageManager sharedManager] removeUserFile:_entry.userFilename
                                         completion:^(NSError *error) {
         
                                             _entry.userFilename = nil;
                                             [self formDidChanged:self];
                                             [self loadCoverImageWithEntry:_entry
                                                                completion:^(UIImage *image, NSError *error) {
                                                                    
                                                                    _bookImage.image = image;
                                                                }];
                                         }];
}

#pragma mark - MayImagePickerDelegate

- (void)imagePicker:(MayImagePickerController *)controller
     didSelectImage:(UIImage *)image {
    
    [controller dismissViewControllerAnimated:YES
                                   completion:NULL];
    MayImageCropperController *picker =
    [[MayImageCropperController alloc] initWithOriginalImage:image];
    
    picker.delegate = self;
    
    [self presentViewController:picker
                       animated:NO
                     completion:nil];
}

- (void)imagePickerDidCancel:(MayImagePickerController *)controller {
    
    [controller dismissViewControllerAnimated:YES
                                   completion:NULL];
}

#pragma mark - MayImageCropperDelegate

- (void)imageCropper:(MayImageCropperController *)controller
     didCaptureImage:(UIImage *)image {
    
    //    __weak typeof(self)weakSelf = self;
    
    [controller dismissViewControllerAnimated:YES
                                   completion:^() {
                                       MayImageManager *imageManager = [MayImageManager sharedManager];
                                       [imageManager storeImage:image
                                                     completion:^(NSString *filename, NSError *error) {
                                                         
                                                         [self formDidChanged:nil];
                                                         [self loadCoverImageWithEntry:_entry
                                                                            completion:^(UIImage *image, NSError *error) {
                                                                                
                                                                                _bookImage.image = image;
                                                                            }];
                                                         
                                                         if (error == nil) {
                                                             _entry.userFilename = filename;
                                                         }
                                                         else {
                                                             [App viewController:self
                                                                 handleUserError:error
                                                                           title:nil];
                                                         }
                                                     }];
                                   }];
}

- (void)imageCropperDidCancel:(MayImageCropperController *)controller {
    
    [controller dismissViewControllerAnimated:YES
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
