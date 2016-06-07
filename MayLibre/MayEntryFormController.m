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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        
        [managedObjectContext rollback];
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
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Save", @"Save");
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
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Create", @"Create");
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
    
    NSError *error = nil;
    
    [managedObjectContext save:&error];
    
    if (error) {
        [App viewController:self
            handleUserError:error
                      title:nil];
    }
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextViewDelegates

- (void)textViewDidChange:(UITextView *)textView {
    
    [self refreshTableViewCellAutolayout];
    [self formDidChanged:textView];
}

#pragma mark IBActions

- (IBAction)updateButtonTaped:(UIBarButtonItem *)sender {

    [self saveForm];
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"openEntrySummaryEditSegue"]) {
        MayEntrySummaryFormController * controller = segue.destinationViewController;
        controller.entry = _entry;
    }
}

@end
