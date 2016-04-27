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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *printType;
@property (weak, nonatomic) IBOutlet UILabel *publishedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisher;

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
    self.titleLabel.text = [managedObject valueForKey:@"title"];
    self.authorLabel.text = [managedObject valueForKey:@"authors"];
    self.printType.text = [managedObject valueForKey:@"printType"];
    self.publisher.text= [managedObject valueForKey:@"publisher"];
    self.publishedDateLabel.text= [managedObject valueForKey:@"publishedDate"];
    
    self.delegate = delegate;
}



@end
