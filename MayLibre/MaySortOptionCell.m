#import "MaySortOptionCell.h"
#import "MayTableViewOptionsBag.h"

@interface MaySortOptionCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation MaySortOptionCell
    
- (void)awakeFromNib {

    [super awakeFromNib];
    
    _textColor = [UIColor colorWithRed:(0.0/255.0)
                                 green:(00./255.0)
                                  blue:(0.0/255.0)
                                 alpha:1.0];
}

- (void)configureCellWithSortOption:(NSDictionary *)sortOption
                        atIndexPath:(NSIndexPath *)indexPath
                           selected:(BOOL)selected {
    
    self.label.text = NSLocalizedString([sortOption valueForKey:MayTableViewOptionsBagItemTextKey], nil);
    self.tag = [[sortOption objectForKey:MayTableViewOptionsBagItemKeyKey] integerValue];
    
    if (selected) {
        self.label.textColor = [self tintColor];
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        self.label.textColor = _textColor;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
