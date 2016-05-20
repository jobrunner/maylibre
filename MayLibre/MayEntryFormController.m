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
    
    if (_isbn != nil) {
        // suche im Hintergrund starten
        // Ergebnisse anzeigen
    }
}

#pragma form helper

- (void)formDidChanged:(id)sender {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark IBActions

- (IBAction)authorTextFieldEditingDidEnd:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)titleTextFieldEditingDidEnd:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)subtitleTextFieldEditingDidEnd:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)yearTextFieldEditingDidEnd:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)publisherTextFieldEditingDidEnd:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)pagesTextFieldEditingDidEnd:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

- (IBAction)isbnEditingDidEnd:(UITextField *)sender {
    
    [self formDidChanged:sender];
}

@end
