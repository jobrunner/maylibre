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
#import "Store.h"
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"

@interface MayEntryDetailsController ()

@property (nonatomic, weak) IBOutlet UIImageView *coverThumbnail;
@property (nonatomic, weak) IBOutlet UILabel *authorsLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleCompositionLabel;
@property (nonatomic, weak) IBOutlet UILabel *productCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *pagesLabel;
@property (nonatomic, weak) IBOutlet UILabel *placeLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherLabel;
@property (nonatomic, weak) IBOutlet UILabel *publishingLabel;
@property (nonatomic, weak) IBOutlet UITextView *notesTextView;
@property (nonatomic, weak) IBOutlet UILabel *summaryLabel;
@property (nonatomic, weak) IBOutlet UILabel *createdDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *updatedDateLabel;
@property (nonatomic, weak) IBOutlet UITextView *notes;
@property (nonatomic, weak) IBOutlet UISwitch *markedSwitch;
@property (nonatomic, weak) IBOutlet UITableViewCell *productCell;

- (IBAction)markedSwitcheValueChanged:(UISwitch *)sender;
- (IBAction)exportToMailTouchUpInside:(UIButton *)sender;
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
    
    _notesTextView.delegate = self;
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = 44;

    UITapGestureRecognizer *coverZoomRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showImageZoom)];
    [self.coverThumbnail addGestureRecognizer:coverZoomRecognizer];
    
    [self updateViewContent];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    [self updateViewContent];

    // Hack
    // Special handling: Summary field can be visible or unvisible.
    // Animates insertion or removing of summary:
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1
                                                inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    // apply changes
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"openEntryFormSegue"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        
        MayEntryFormController *controller = [navigationController.viewControllers firstObject];
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

    // hide empty description cell
    if ((indexPath.section == 0) &&
        (indexPath.row == 1) &&
        (_summaryLabel.text.length == 0)) {
     
        return 0.0;
    }
    
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

/**
 * Asks, removes and go back to the list or do nothing.
 */
- (IBAction)deleteEntryTouchUpInside:(UIButton *)sender {

    void (^action)() = ^{

        [App.store deleteObject:_entry];

        NSError *error = nil;
        
        if (![App.store save:&error]) {
            [App viewController:self
                handleUserError:error
                          title:nil];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
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
                                            style:UIAlertActionStyleCancel
                                          handler:nil];
    [actionSheet addAction:deleteAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

#pragma mark MayEntryDetailsController


- (void)updateViewContent {
    
    if (_entry.authors.length > 0) {
        _authorsLabel.text = _entry.authors;
    }
    else {
        _authorsLabel.text = NSLocalizedString(@"No author", nil);
    }

    NSString *title;
    if (_entry.title.length > 0) {
        title = [NSString stringWithFormat:@"%@.", _entry.title];
    }
    else {
        title = NSLocalizedString(@"No title", nil);
    }

    NSString *subtitle = nil;
    if (_entry.subtitle.length > 0) {
        subtitle = [NSString stringWithFormat:@"%@.", _entry.subtitle];
    }

    if (subtitle) {
        _titleCompositionLabel.text = [NSString stringWithFormat:@"%@ %@", title, subtitle];
    }
    else {
        _titleCompositionLabel.text = title;
    }

    if (_entry.productCode.length > 0) {
        _productCodeLabel.text = _entry.productCode;
    }
    else {
        _productCodeLabel.text = @"-";
    }
    
    if (_entry.publisher.length > 0) {
        _publisherLabel.text = _entry.publisher;
    }
    else {
        _publisherLabel.text = @"-";
    }
    
    if (_entry.publishing.length > 0) {
        _publishingLabel.text = _entry.publishing;
    }
    else {
        _publishingLabel.text = @"-";
    }

    if (_entry.place.length > 0) {
        _placeLabel.text = _entry.place;
    }
    else {
        _placeLabel.text = @"-";
    }
    
    if (_entry.pageCount.length > 0) {
        _pagesLabel.text = _entry.pageCount;
    }
    else {
        _pagesLabel.text = @"-";
    }
    
    _summaryLabel.text = _entry.summary;
    _notesTextView.text = _entry.notes;
    _markedSwitch.on = _entry.isMarked.boolValue;
    
    NSString *imageUrl = _entry.coverUrl;

    if (_entry.userFilename != nil) {
        
        self.coverThumbnail.image = [[MayImageManager sharedManager] imageWithFilename:_entry.userFilename];
    }
    else {
    
        [[MayImageManager sharedManager] imageWithUrlString:imageUrl
                                                 completion:^(UIImage *image, NSError *error) {

                                                     self.coverThumbnail.image = image;
                                                 
                                                 }];
    }

    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    _createdDateLabel.text = [formatter stringFromDate:_entry.creationTime];
    _updatedDateLabel.text = [formatter stringFromDate:_entry.updateTime];
}

- (void)saveForm {
    
    _entry.notes = _notes.text;
    _entry.isMarked = @(_markedSwitch.on);

    NSError *error = nil;
    
    if (![App.store save:&error]) {
        [App viewController:self
            handleUserError:error
                      title:nil];
    }
    
}

- (void)showImageZoom {
    
    TGRImageViewController *viewController =
    [[TGRImageViewController alloc] initWithImage:self.coverThumbnail.image];
    
    viewController.transitioningDelegate = self;
    
    [self presentViewController:viewController
                       animated:YES
                     completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.coverThumbnail];
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.coverThumbnail];
    }
    
    return nil;
}

@end
