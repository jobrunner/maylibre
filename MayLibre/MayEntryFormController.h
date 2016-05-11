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

@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UITextView *authorsTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *publisherTextField;
@property (weak, nonatomic) IBOutlet UITextField *pagesTextField;
@property (weak, nonatomic) IBOutlet UITextField *isbnTextField;

- (IBAction)titleTextFieldEditingDidEnd:(UITextField *)sender;
- (IBAction)subtitleTextFieldEditingDidEnd:(UITextField *)sender;
- (IBAction)yearTextFieldEditingDidEnd:(UITextField *)sender;
- (IBAction)publisherTextFieldEditingDidEnd:(UITextField *)sender;
- (IBAction)pagesTextFieldEditingDidEnd:(UITextField *)sender;
- (IBAction)isbnEditingDidEnd:(UITextField *)sender;

@end
