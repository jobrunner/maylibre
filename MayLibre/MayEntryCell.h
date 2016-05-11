//
//  ItemCell.h
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import UIKit;

#import "MGSwipeTableCell.h"

@interface MayEntryCell : MGSwipeTableCell

@property (strong, nonatomic) NSIndexPath *indexPath;

- (void)configureWithModel:(NSManagedObject *)managedObject
               atIndexPath:(NSIndexPath *)indexPath
              withDelegate:(id<MGSwipeTableCellDelegate>)delegate;

@end
