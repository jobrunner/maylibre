//
//  MayEntryFormController.h
//  MayLibre
//
//  Created by Jo Brunner on 26.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import UIKit;
#import "MayISBN.h"
#import "Product.h"

@interface MayEntryFormController : UITableViewController <
    UITextFieldDelegate,
    UITextViewDelegate> {
    
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, strong) MayISBN *isbn;
@property (nonatomic, strong) Product *product;

@property (nonatomic, weak) IBOutlet UITextField *productCodeTextField;

- (IBAction)procutCodeEditingDidEnd:(UITextField *)sender;

@end
