#import "FetchedResultsControllerDataSource.h"

@interface FetchedResultsControllerDataSource ()

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) UITableView* tableView;

@end

@implementation FetchedResultsControllerDataSource

#pragma mark Initializers

- (id)initWithTableView:(UITableView*)tableView {
    
    if (self = [super init]) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
    }

    return self;
}

#pragma mark Overrides: UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)sectionIndex {
    
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];

    return section.numberOfObjects;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {

    if (self.nibName == nil) {

        return [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier
                                               forIndexPath:indexPath];
    }
    
    id cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:self.nibName
                                              bundle:nil]
        forCellReuseIdentifier:self.reuseIdentifier];
        
        cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView
canEditRowAtIndexPath:(NSIndexPath*)indexPath {
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

#pragma mark Implements: NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
    
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
    
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath*)newIndexPath {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark FetchedResultsControllerDataSource

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        
        return _fetchedResultsController;
    }

    _fetchedResultsController = [self.delegate fetchedResultsControllerDataSource:self];
    
    if (_fetchedResultsController.delegate == nil) {
        
        _fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

- (void)refresh {

    _fetchedResultsController = nil;
}

@end
