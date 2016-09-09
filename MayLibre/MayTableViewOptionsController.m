#import "MayTableViewOptionsController.h"
#import "MaySortOptionCell.h"
#import "MayFilterOptionCell.h"
#import "MayActionOptionCell.h"
#import "MayTableViewOptionsBag.h"

@interface MayTableViewOptionsController ()

@property (nonatomic, strong) NSArray *sortOptions;
@property (nonatomic, strong) NSArray *filterOptions;
@property (nonatomic, strong) NSArray *actionOptions;

- (IBAction)doneButton:(UIBarButtonItem *)sender;

@end

@implementation MayTableViewOptionsController {
    
    MayTableViewOptionsBag *optionBag;
}

#pragma mark UITableViewControllerDelegates

- (void)viewDidLoad {
    
    [super viewDidLoad];

    optionBag = [MayTableViewOptionsBag sharedInstance];
    
    _sortOptions = [optionBag sortOptions:self.entity];
    _filterOptions = [optionBag filterOptions:self.entity];

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    [self.navigationController setToolbarHidden:YES
                                       animated:NO];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:NO];
    self.tableView.estimatedRowHeight = 28;
    self.tableView.rowHeight = 28;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // sections: sorting, filtering, defaults
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return [[optionBag sortOptions:self.entity] count];
    }
    else if (section == 1) {
        return [[optionBag filterOptions:self.entity] count];
    }
    else if (section == 2) {
        return [[optionBag actionOptions:self.entity] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Sort section
    if (indexPath.section == 0) {
        static NSString *cellId = @"MaySortOptionCell";
    
        MaySortOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
        if (!cell) {
            UINib *nib = [UINib nibWithNibName:cellId
                                        bundle:nil];
            [tableView registerNib:nib
            forCellReuseIdentifier:cellId];
        
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        }

        return cell;
    }

    if (indexPath.section == 1) {
        static NSString *cellId = @"MayFilterOptionCell";
        
        MayFilterOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (!cell) {
            UINib *nib = [UINib nibWithNibName:cellId
                                        bundle:nil];
            [tableView registerNib:nib
            forCellReuseIdentifier:cellId];
            
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        }
        
        return cell;
    }
    
    if (indexPath.section == 2) {
        static NSString *cellId = @"MayActionOptionCell";
        
        MayActionOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (!cell) {
            UINib *nib = [UINib nibWithNibName:cellId
                                        bundle:nil];
            [tableView registerNib:nib
            forCellReuseIdentifier:cellId];
            
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        }
        
        return cell;
    }
    
    // dummy cell
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Sort options section cells
    if (indexPath.section == 0) {
        NSDictionary *sortOption = [[optionBag sortOptions:self.entity] objectAtIndex:indexPath.row];
        NSInteger activeSortOptionKey = [optionBag sortOptionKey:self.entity];

        BOOL selected =
        (activeSortOptionKey == [[sortOption objectForKey:kMayTableViewOptionsBagItemIdKey] integerValue]);

        [(MaySortOptionCell *)cell configureCellWithSortOption:sortOption
                                                   atIndexPath:indexPath
                                                      selected:selected];
    }

    // @todo
    // Filter options section cells
    if (indexPath.section == 1) {
        cell = (MayFilterOptionCell *)cell;
        cell.textLabel.text = @"Dummy";
    }
    
    // Action section cells
    if (indexPath.section == 2) {
        NSDictionary *actionOption = [[optionBag actionOptions:self.entity]
                                      objectAtIndex:indexPath.row];
 
        cell = (MayActionOptionCell *)cell;
        [(MayActionOptionCell *)cell configureCellWithActionOption:actionOption
                                                            action:^(UIButton *sender) {
                                                                [self setTableViewDefaults];
                                                                [self.tableView reloadData];
                                                            }];
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // sort by section
    if (indexPath.section == 0) {
        MaySortOptionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSInteger selectedKey = cell.tag;
        
        [optionBag setSortOptionKey:selectedKey
                          forEntity:self.entity];
        
        NSDictionary *sortOption = [optionBag sortOptionWithKey:selectedKey
                                                          entry:self.entity];
        
        NSIndexSet *section = [NSIndexSet indexSetWithIndex:indexPath.section];
        [tableView reloadSections:section
                 withRowAnimation:UITableViewRowAnimationFade];
        
        if ([self.delegate respondsToSelector:@selector(tableViewOptionsController:didSelectSortOption:)]) {
            [self.delegate tableViewOptionsController:self
                                  didSelectSortOption:sortOption];
        }
    }
    
    // filter section
    if (indexPath.section == 1) {
        MayFilterOptionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
    }
    
    if (indexPath.section == 2) {
        MayActionOptionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSDictionary *actionOption = [optionBag actionOptionWithKey:cell.tag
                                                              entry:self.entity];
        
        if ([self.delegate respondsToSelector:@selector(tableViewOptionsController:didSelectActionOption:)]) {
            [self.delegate tableViewOptionsController:self
                                didSelectActionOption:actionOption];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return ([[optionBag sortOptions:self.entity] count] > 0) ? UITableViewAutomaticDimension : 0.01;
    }
    else if (section == 1) {
        return ([[optionBag filterOptions:self.entity] count] > 0) ? UITableViewAutomaticDimension : 0.01;
    }
    else if (section == 2) {
        
        return ([[optionBag actionOptions:self.entity] count] > 0) ? UITableViewAutomaticDimension : 0.01;
    }
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return ([[optionBag sortOptions:self.entity] count] > 0) ? NSLocalizedString(@"Sort by", nil) : @"";
    }
    else if (section == 1) {
        return ([[optionBag filterOptions:self.entity] count] > 0) ? NSLocalizedString(@"Filter", nil) : @"";
    }
    else if (section == 2) {
        return ([[optionBag actionOptions:self.entity] count] > 0) ? NSLocalizedString(@"", nil) : @"";
    }

    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

#pragma mark IBActions

- (IBAction)doneButton:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark MayTableViewOptionsController functions

- (void)setTableViewDefaults {
    
    NSDictionary *defaults = [optionBag defaultOptions:self.entity];
    NSInteger sortKey = [[defaults objectForKey:kMayTableViewOptionsBagSectionSortDefaultId] integerValue];
    NSInteger filterKey = [[defaults objectForKey:kMayTableViewOptionsBagSectionFilterDefaultId] integerValue];
    
    // wenn sich etwas verändert, dann
    // set bag
    // refresh
    // delegate aufrufen
    
    if ([optionBag sortOptionKey:self.entity] != sortKey) {
        
        [optionBag setSortOptionKey:sortKey
                          forEntity:self.entity];
        
        NSDictionary *sortOption = [optionBag sortOptionWithKey:sortKey
                                                          entry:self.entity];
        
        if ([self.delegate respondsToSelector:@selector(tableViewOptionsController:didSelectSortOption:)]) {
            [self.delegate tableViewOptionsController:self
                                  didSelectSortOption:sortOption];
        }
    }
    
    if ([optionBag filterOptionKey:self.entity] != filterKey) {
        
        [optionBag setFilterOptionKey:filterKey
                            forEntity:self.entity];
        
        NSDictionary *filterOption = [optionBag filterOptionWithKey:filterKey
                                                              entry:self.entity];
        
        if ([self.delegate respondsToSelector:@selector(tableViewOptionsController:didSelectFilterOption:)]) {
            [self.delegate tableViewOptionsController:self
                                didSelectFilterOption:filterOption];
        }
    }
}

@end
