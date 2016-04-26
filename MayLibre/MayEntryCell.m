//
//  ItemCell.m
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "MayEntryCell.h"
#import "Product.h"

@interface MayEntryCell()

@property (nonatomic, weak) IBOutlet UILabel *productCodeLabel;
@property (nonatomic, weak) id delegate;

@end

@implementation MayEntryCell

- (void)awakeFromNib {

    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {

    [super setSelected:selected
              animated:animated];
}

- (void)configureWithModel:(NSManagedObject *)managedObject
               atIndexPath:(NSIndexPath *)indexPath
              withDelegate:(id)delegate {
    
    self.indexPath = indexPath;
    self.productCodeLabel.text = [managedObject valueForKey:@"productCode"];
    self.delegate = delegate;
}



@end
