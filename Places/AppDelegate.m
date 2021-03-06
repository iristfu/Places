//
//  AppDelegate.m
//  Places
//
//  Created by Iris Fu on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "ItineraryDetailViewController.h"
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        configuration.applicationId = @"ZT44nRZeD29iUf4OIYBLgw0gw79FkC1VGyruGBMb";
        configuration.clientKey = @"XTQpnjPluMtMMNwmPibGJle4hLtAINA4XJaRmUTX";
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    
    [GMSPlacesClient provideAPIKey:@"AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE"];
    
    return YES;
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"url recieved: %@", url.absoluteString);
    NSLog(@"host: %@", [url host]);
    NSLog(@"url path: %@", [url path]);
    NSString *itineraryObjectID = [[url path] substringFromIndex:1]; // remove "/" from path
    NSLog(@"itineraryObjectID: %@", itineraryObjectID);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ItineraryDetailViewController *itineraryDetailViewController =[storyboard instantiateViewControllerWithIdentifier:@"ItineraryDetailView"];
    NSLog(@"Have an itinerary Detail View Controller %@", itineraryDetailViewController);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
    [query getObjectInBackgroundWithId:itineraryObjectID block:^(PFObject *itinerary, NSError *error) {
        if (!error) {
            itineraryDetailViewController.itinerary = itinerary;
            NSLog(@"Got the itinerary to set the detail view with itinerary %@", itineraryDetailViewController.itinerary);
            
            UITabBarController *tabBarController = self.window.rootViewController;
            [tabBarController setSelectedIndex:2];
            [[tabBarController selectedViewController] pushViewController:itineraryDetailViewController animated:true];
        }
    }];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentCloudKitContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentCloudKitContainer alloc] initWithName:@"Places"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
