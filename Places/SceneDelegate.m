//
//  SceneDelegate.m
//  Places
//
//  Created by Iris Fu on 7/5/22.
//

#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "ItineraryDetailViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
@import Parse;


@interface SceneDelegate () <LoginViewControllerDelegate, SignUpViewControllerDelegate>

@end

@implementation SceneDelegate

- (void)userDidLogin {
    NSLog(@"userDidLogin called");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    NSLog(@"Performed userDidLogin");
}

- (void)userDidSignUp {
    NSLog(@"userDidSignup called");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    NSLog(@"Performed userDidSignup");
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    NSLog(@"Will connect to session called with session %@ and options %@", session, connectionOptions);
    
    // If the user is already logged in, upon relaunching the app, don't need to login again
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    }
    // In future PR: may need to handle custom URL here for when the app isn't launched and the user clicks a custom URL
}


- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSLog(@"This should be called if app opens a URL while running or suspended in memory");
    NSURL *url = [[URLContexts allObjects] firstObject].URL;
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
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.

    // Save changes in the application's managed object context when the application transitions to the background.
    [(AppDelegate *)UIApplication.sharedApplication.delegate saveContext];
}


@end
