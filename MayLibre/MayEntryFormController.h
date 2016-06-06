//
//  MayEntryFormController.h
//  MayLibre
//
//  Created by Jo Brunner on 26.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import UIKit;
#import "MayISBN.h"
#import "Entry.h"

@interface MayEntryFormController : UITableViewController <
    UITextFieldDelegate,
    UITextViewDelegate> {
    
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, strong) MayISBN *isbn;
@property (nonatomic, strong) Entry *entry;

@property (weak, nonatomic) IBOutlet UITableViewCell *authorsCell;
@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UITextView *authorsTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *publisherTextField;
@property (weak, nonatomic) IBOutlet UITextField *pagesTextField;
@property (weak, nonatomic) IBOutlet UITextField *isbnTextField;
@property (weak, nonatomic) IBOutlet UITextField *placeTextField;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *summaryCell;

- (IBAction)updateButtonTaped:(UIBarButtonItem *)sender;
- (IBAction)titleTextFieldChanged:(UITextField *)sender;
- (IBAction)subtitleTextFieldChanged:(UITextField *)sender;
- (IBAction)yearTextFieldChanged:(UITextField *)sender;
- (IBAction)publisherTextFieldChanged:(UITextField *)sender;
- (IBAction)pagesTextFieldChanged:(UITextField *)sender;
- (IBAction)isbnTextFieldChanged:(UITextField *)sender;
- (IBAction)placeTextFieldChanged:(UITextField *)sender;

@end
