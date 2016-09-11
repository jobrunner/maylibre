@import UIKit;

@protocol MayTableViewOptionsControllerDelegate;

@interface MayTableViewOptionsController : UITableViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSString *entity;
@property (nonatomic, weak) id<MayTableViewOptionsControllerDelegate> delegate;

@end

@protocol MayTableViewOptionsControllerDelegate <NSObject>

@optional

- (void)tableViewOptionsController:(MayTableViewOptionsController *)controller
                didSelectSortOption:(NSDictionary *)sortOption;

- (void)tableViewOptionsController:(MayTableViewOptionsController *)controller
             didSelectFilterOption:(NSDictionary *)filterOption;

- (void)tableViewOptionsController:(MayTableViewOptionsController *)controller
             didSelectActionOption:(NSDictionary *)actionOption;
@end