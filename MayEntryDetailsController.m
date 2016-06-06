//
//  MayEntryDetailsController.m
//  MayLibre
//
//  Created by Jo Brunner on 02.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "AppDelegate.h"
#import "MayEntryDetailsController.h"
#import "MayEntryFormController.h"
#import "MayImageManager.h"
#import "Entry.h"

@interface MayEntryDetailsController ()

@property (weak, nonatomic) IBOutlet UIImageView *coverThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *authorsLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleCompositionLabel;
@property (nonatomic, weak) IBOutlet UILabel *productCodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *pagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishingLabel;

@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *notes;
@property (weak, nonatomic) IBOutlet UISwitch *markedSwitch;

@property (weak, nonatomic) IBOutlet UITableViewCell *productCell;
- (IBAction)markedSwitcheValueChanged:(UISwitch *)sender;
- (IBAction)exportToMailTouchUpInside:(id)sender;
- (IBAction)deleteEntryTouchUpInside:(UIButton *)sender;

@end

@implementation MayEntryDetailsController

#pragma mark UIViewControllerDelegates

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:NO];
    managedObjectContext = App.managedObjectContext;
    
    _notesTextView.delegate = self;
    
    self.tableView.estimatedRowHeight = 44;

    _authorsLabel.text = _entry.authors;
    _titleCompositionLabel.text = [NSString stringWithFormat:@"%@. %@.", _entry.title, _entry.subtitle];
    _productCodeLabel.text = _entry.productCode;
    _publisherLabel.text = _entry.publisher;
    _publishingLabel.text = _entry.publishing;
    _placeLabel.text = _entry.place;
    _notesTextView.text = _entry.notes;
    _markedSwitch.on = _entry.isMarked.boolValue;
    
    NSString *imageUrl = _entry.coverUrl;
    
    [[MayImageManager sharedManager] imageWithUrlString:imageUrl
                                             completion:^(UIImage *image, NSError *error) {
                                                 if (error) {
                                                     [App viewController:self
                                                         handleUserError:error
                                                                   title:nil];
                                                 }
                                                 self.coverThumbnail.image = image;
                                             }];

    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    _createdDateLabel.text = [formatter stringFromDate:_entry.creationTime];
    _updatedDateLabel.text = [formatter stringFromDate:_entry.updateTime];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"openEntryFormSegue"]) {
        
        MayEntryFormController *controller =
        (MayEntryFormController *)segue.destinationViewController;
        
        controller.entry = _entry;
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

#pragma mark UITextViewDelegates

/**
 * Makes it possible to expand text view during input.
 * It's a hack that stabilizes autolayout animations during text changes.
 */
- (void)textViewDidChange:(UITextView *)textView {
    
    CGPoint currentOffset = [self.tableView contentOffset];
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    [self.tableView setContentOffset:currentOffset
                            animated:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    // store ad-hoc
    [self saveForm];
}

#pragma mark IBActions

- (IBAction)markedSwitcheValueChanged:(UISwitch *)sender {

    // store ad-hoc
    [self saveForm];
}

- (IBAction)exportToMailTouchUpInside:(id)sender {

    // see swipe sendMail - place functionality in a single place and call it.
}

- (IBAction)deleteEntryTouchUpInside:(UIButton *)sender {

    // ask, remove and go back to the list or do nothing.
}

#pragma mark MayEntryDetailsController

- (void)saveForm {
    
    _entry.notes = _notes.text;
    _entry.isMarked = @(_markedSwitch.on);

    NSError *error = nil;
    
    [managedObjectContext save:&error];
    
    if (error) {
        [App viewController:self
            handleUserError:error
                      title:nil];
    }
}

@end
