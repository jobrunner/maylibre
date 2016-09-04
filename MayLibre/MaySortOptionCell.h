@import UIKit;

@interface MaySortOptionCell : UITableViewCell

- (void)configureCellWithSortOption:(NSDictionary *)sortOption
                        atIndexPath:(NSIndexPath *)indexPath
                           selected:(BOOL)selected;
@end
