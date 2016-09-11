#import "MayActionOptionCell.h"
#import "MayTableViewOptionsBag.h"

@interface MayActionOptionCell ()

@property (nonatomic, copy) void(^action)(UIButton *sender);

@property (nonatomic, weak) IBOutlet UIButton *applyActionButton;

- (IBAction)applyAction:(UIButton *)sender;

@end

@implementation MayActionOptionCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)configureCellWithActionOption:(NSDictionary *)actionOption
                               action:(void(^)(UIButton *sender))action {
  
    self.tag = (NSInteger)[actionOption objectForKey:MayTableViewOptionsBagItemKeyKey];

    [self.applyActionButton setTitle:NSLocalizedString([actionOption objectForKey:MayTableViewOptionsBagItemTextKey], nil)
                            forState: UIControlStateNormal];
    
    self.action = action;
}

- (IBAction)applyAction:(UIButton *)sender {

    if (self.action == nil) {
        
        return;
    }
    
    self.action(sender);
}

@end
