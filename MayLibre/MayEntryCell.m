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

@end

@implementation MayEntryCell

- (void)awakeFromNib {
    
    //configure right swipe buttons
    self.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" // Delete, index = 1
                                                    icon:[UIImage imageNamed:@"trash"]
                                         backgroundColor:[UIColor redColor]
                                                 padding:28],
                          [MGSwipeButton buttonWithTitle:@""  // Mark, index = 2
                                                    icon:[UIImage imageNamed:@"star"]
                                         backgroundColor:[UIColor orangeColor]
                                                 padding:28],
                          [MGSwipeButton buttonWithTitle:@""  // Mail (export), index = 3
                                                    icon:[UIImage imageNamed:@"mail"]
                                         backgroundColor:[UIColor lightGrayColor]
                                                 padding:28]];
    self.rightSwipeSettings.transition = MGSwipeTransitionBorder;
}

- (void)configureWithModel:(NSManagedObject *)managedObject
               atIndexPath:(NSIndexPath *)indexPath
              withDelegate:(id)delegate {
    
    // handle not to show (null) when string is nil.
    
    self.indexPath = indexPath;
    _productCodeLabel.text = [managedObject valueForKey:@"productCode"];
    
    // handle last point for subtitle.
    NSString *title = [managedObject valueForKey:@"title"];
    
    if (title == nil) {
        title = [NSString stringWithFormat:@""];
    }
    
    NSString *subtitle = [managedObject valueForKey:@"subtitle"];
    
    if (subtitle == nil) {
        subtitle = @"";
    }
    
    _titleCompositionLabel.text = [NSString stringWithFormat:@"%@. %@",
                                       title,
                                       subtitle];
    _authorLabel.text = [[managedObject valueForKey:@"authors"] stringByReplacingOccurrencesOfString:@"\n"
                                                                                              withString:@", "];
    
    NSString *imageUrl = [managedObject valueForKey:@"coverUrl"];
    NSString *userFilename = [managedObject valueForKey:@"userFilename"];
    
    MayImageManager *imageManager = [MayImageManager sharedManager];

    if (userFilename != nil) {
    
        self.coverThumbnail.image = [imageManager imageWithFilename:userFilename];
    }
    else {
        [imageManager imageWithUrlString:imageUrl
                              completion:^(UIImage *image, NSError *error) {
                                  if (error) {
                                      NSLog(@"Error while trying to fetch cover: %@",
                                            error.localizedDescription);
                                  }
                                  self.coverThumbnail.image = image;
                              }];
    }
    self.delegate = delegate;
    
    if ([[managedObject valueForKey:@"isMarked"] boolValue]) {
    
        _authorLabel.textColor = UIColor.orangeColor;
        _titleCompositionLabel.textColor = UIColor.orangeColor;
    }
    else {
        
        _authorLabel.textColor = UIColor.blackColor;
        _titleCompositionLabel.textColor = UIColor.blackColor;
    }
}

@end
