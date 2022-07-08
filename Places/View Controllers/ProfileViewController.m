//
//  ProfileViewController.m
//  Places
//
//  Created by Iris Fu on 7/8/22.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "SceneDelegate.h"
@import Parse;

@interface ProfileViewController ()
- (IBAction)didTapLogout:(id)sender;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapLogout:(id)sender {
    // logout the user
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
    
    // return to login screen
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = profileViewController;
}

@end
