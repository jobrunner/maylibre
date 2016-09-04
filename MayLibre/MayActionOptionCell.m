#import "MayActionOptionCell.h"

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
  
    self.tag = (NSInteger)[actionOption objectForKey:@"tag"];

    [self.applyActionButton setTitle:NSLocalizedString([actionOption objectForKey:@"textkey"], nil)
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
