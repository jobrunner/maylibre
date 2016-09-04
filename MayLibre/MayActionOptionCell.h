@import UIKit;

@interface MayActionOptionCell : UITableViewCell

- (void)configureCellWithActionOption:(NSDictionary *)actionOption
                               action:(void(^)(UIButton *sender))action;

@end
