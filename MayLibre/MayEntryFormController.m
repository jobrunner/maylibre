//
//  MayEntryFormController.m
//  MayLibre
//
//  Created by Jo Brunner on 26.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "AppDelegate.h"
#import "MayEntryFormController.h"
#import "MayImageManager.h"

@implementation MayEntryFormController

#pragma mark UITableViewController Delegates

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
    self.authorsTextView.delegate = self;
    
    managedObjectContext = ApplicationDelegate.managedObjectContext;
    
    if (_entry == nil) {
        [self createModelForEditing];
    }
    else {
        [self loadModelForUpdate];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)loadModelForUpdate {
    
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Save", @"Save");
    self.navigationItem.rightBarButtonItem.enabled = false;

    _authorsTextView.text = _entry.authors;
    _titleTextField.text = _entry.title;
    _subtitleTextField.text = _entry.subtitle;
    _yearTextField.text = _entry.publishedDate;
    _publisherTextField.text = _entry.publisher;
    _pagesTextField.text = _entry.pageCount;
    _isbnTextField.text = _entry.productCode;
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
    
    self.entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"
                                                inManagedObjectContext:managedObjectContext];
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Create", @"Create");
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    _authorsTextView.text = @"";
    _titleTextField.text = @"";
    _subtitleTextField.text = @"";
    _yearTextField.text = @"";
    _publisherTextField.text = @"";
    _pagesTextField.text = @"";
    _isbnTextField.text = @"";
}

- (void)saveForm {
    
    _entry.authors = _authorsTextView.text;
    _entry.title = _titleTextField.text;
    _entry.subtitle = _subtitleTextField.text;
    _entry.publishedDate = _yearTextField.text;
    _entry.publisher = _publisherTextField.text;
    _entry.pageCount = _pagesTextField.text;
    _entry.productCode = _isbnTextField.text;
    
    NSError *error = nil;
    
    [managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

#pragma mark - Helper

- (void)formDidChanged:(id)sender {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)goToPreviousViewController {
    
    UINavigationController *navigationController =
    self.navigationController;
    
    [navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextView Delegates

- (void)textViewDidChange:(UITextView *)textView {
    
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

@end
