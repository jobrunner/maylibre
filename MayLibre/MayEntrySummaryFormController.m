//
//  MayEntrySummaryFormController.m
//  MayLibre
//
//  Created by Jo Brunner on 01.06.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "AppDelegate.h"
#import "MayEntrySummaryFormController.h"
#import "MayEntrySummaryFormCell.h"
#import "Entry.h"

@implementation MayEntrySummaryFormController

#pragma mark UIViewControllerDelegates

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = false;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tableView.estimatedRowHeight = 70;
    
    _entrySummaryTextView.delegate = self;
    _entrySummaryTextView.text = _entry.summary;
    
    [_entrySummaryTextView becomeFirstResponder];
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

#pragma mark UITextViewDelegates

- (void)textViewDidChange:(UITextView *)textView {
    
    CGPoint currentOffset = [self.tableView contentOffset];
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    [self.tableView setContentOffset:currentOffset
                            animated:NO];
    [self formDidChanged:textView];
}

#pragma mark IBActions

- (IBAction)done:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEntrySummaryChanged
                                                        object:_entrySummaryTextView.text];
    [self closeViewController];
}

- (IBAction)cancel:(id)sender {
    
    [self closeViewController];
}

#pragma mark MayEntrySummaryFormController

- (void)closeViewController {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formDidChanged:(id)sender {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

@end
