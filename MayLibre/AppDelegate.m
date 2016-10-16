//
//  AppDelegate.m
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataStack.h"
#import "Store.h"

@interface AppDelegate ()

@property (nonatomic, strong, readwrite) Store* store;

@end

@implementation AppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // initialize store service layer instance that manages core data stack
    self.store = [Store new];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    NSError *error = nil;

    [self.store save:&error];

    if (error != nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Error handling

- (void)viewController:(UIViewController *)viewController
       handleUserError:(NSError *)error
                 title:(NSString *)title {
    
    if (!error) {
        
        return;
    }
    
    NSLog(@"%@", error.localizedDescription);
    
    if (title == nil) {
        title = NSLocalizedString(@"Error", nil);
    }
    
    UIAlertController *actionAlert =
    [UIAlertController alertControllerWithTitle:title
                                        message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [actionAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                    style:UIAlertActionStyleDefault
                                                  handler:nil]];
    
    
    [viewController presentViewController:actionAlert
                                 animated:YES
                               completion:nil];
}

- (void)viewConroller:(UIViewController *)viewController
                title:(NSString *)title
              message:(NSString*)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil];
    [alertController addAction:alertAction];
    
    [viewController presentViewController:alertController
                                 animated:YES
                               completion:nil];
}

@end
