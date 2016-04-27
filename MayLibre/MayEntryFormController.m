//
//  MayEntryFormController.m
//  MayLibre
//
//  Created by Jo Brunner on 26.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "AppDelegate.h"
#import "MayEntryFormController.h"

@implementation MayEntryFormController

#pragma mark UITableViewController Delegates

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    managedObjectContext = ApplicationDelegate.managedObjectContext;
    
    if (_product == nil) {
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

    _productCodeTextField.text = _product.productCode;
}

- (void)createModelForEditing {
    
    self.product = [NSEntityDescription insertNewObjectForEntityForName:@"Product"
                                                 inManagedObjectContext:managedObjectContext];
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Create", @"Create");
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    if (_isbn != nil) {
        // suche im Hintergrund starten
        // Ergebnisse anzeigen
    }

    
}

- (IBAction)procutCodeEditingDidEnd:(UITextField *)sender {

    // save button aktivieren
}
@end
