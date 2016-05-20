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
#import "Entry.h"
#import "MayImageManager.h"

@interface MayEntryCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverThumbnail;
@property (nonatomic, weak) IBOutlet UILabel *productCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleCompositionLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (weak, nonatomic) IBOutlet UILabel *printType;
@property (weak, nonatomic) IBOutlet UILabel *publisher;
@property (weak, nonatomic) IBOutlet UILabel *publishedDateLabel;

@end

@implementation MayEntryCell

- (void)awakeFromNib {
    
    //configure right swipe buttons
    self.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" // Delete, index = 1
                                                    icon:[UIImage imageNamed:@"trash"]
                                         backgroundColor:[UIColor redColor]
                                                 padding:28],
//                          [MGSwipeButton buttonWithTitle:@""  // Mark, index = 2
//                                                    icon:[UIImage imageNamed:@"star"]
//                                         backgroundColor:[UIColor orangeColor]
//                                                 padding:28]],
                          [MGSwipeButton buttonWithTitle:@""  // Mail (export), index = 3
                                                    icon:[UIImage imageNamed:@"mail"]
                                         backgroundColor:[UIColor lightGrayColor]
                                                 padding:28]];
    self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {

    [super setSelected:selected
              animated:animated];
}

- (void)configureWithModel:(NSManagedObject *)managedObject
               atIndexPath:(NSIndexPath *)indexPath
              withDelegate:(id)delegate {
    
    // handle not to show (null) when string is nil.
    
    self.indexPath = indexPath;
    self.productCodeLabel.text = [managedObject valueForKey:@"productCode"];
    
    // handle last point for subtitle.
    NSString *title = [managedObject valueForKey:@"title"];
    if (title == nil) {
        title = [NSString stringWithFormat:@""];
    }
    NSString *subtitle = [managedObject valueForKey:@"subtitle"];
    if (subtitle == nil) {
        subtitle = @"";
    }
    
    self.titleCompositionLabel.text = [NSString stringWithFormat:@"%@. %@",
                                       title,
                                       subtitle];
    self.authorLabel.text = [[managedObject valueForKey:@"authors"] stringByReplacingOccurrencesOfString:@"\n"
                                                                                              withString:@", "];
    self.printType.text = [managedObject valueForKey:@"printType"];
    self.publisher.text= [managedObject valueForKey:@"publisher"];
    self.publishedDateLabel.text= [managedObject valueForKey:@"publishedDate"];
    
    NSString *imageUrl = [managedObject valueForKey:@"coverUrl"];
    
    [[MayImageManager sharedManager] imageWithUrlString:imageUrl
                                             completion:^(UIImage *image, NSError *error) {
                                                 if (error) {
                                                     NSLog(@"Error while trying to fetch cover: %@",
                                                           error.localizedDescription);
                                                 }
                                                 self.coverThumbnail.image = image;
    }];
    
    self.delegate = delegate;
}

@end
