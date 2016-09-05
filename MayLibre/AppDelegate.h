//
//  AppDelegate.h
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import UIKit;
@import CoreData;

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define App                 ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define kNotificationEntrySummaryChanged    @"EntrySummaryChanged"
#define kMayCommonErrorDomain               @"MayLibreGeneralError"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)viewController:(UIViewController *)viewController
       handleUserError:(NSError *)error
                 title:(NSString *)title;
- (void)viewConroller:(UIViewController *)viewController
                title:(NSString *)title
              message:(NSString*)message;

@end

