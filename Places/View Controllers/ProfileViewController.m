//
//  ProfileViewController.m
//  Places
//
//  Created by Iris Fu on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "SceneDelegate.h"
@import Parse;

@interface ProfileViewController ()
- (IBAction)didTapLogout:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *bio;
@property (weak, nonatomic) IBOutlet PFImageView *profilePicture;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCurrentUserInfo];
}

- (void)setCurrentUserInfo {
    NSLog(@"Setting current user info");
    PFUser *currentUser = [PFUser currentUser];
    self.username.text = [NSString stringWithFormat:@"@%@", currentUser.username];

    if (currentUser[@"profilePicture"]) {
        NSLog(@"Loading user's profile picture");
        self.profilePicture.file = currentUser[@"profilePicture"];
        [self.profilePicture loadInBackground];
    } else {
        UIImage *placeHolderImage = [UIImage imageNamed:@"default_profile_picture"];
        [self.profilePicture setImage:placeHolderImage];
        NSLog(@"Set placeholder image %@", placeHolderImage);
    }
    
    if (currentUser[@"bio"]) {
        self.bio.text = currentUser[@"bio"];
    } else {
        self.bio.text = @"Joined Summer 2022. Excited to be using Places :)";
    }
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
