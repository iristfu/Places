//
//  SignUpViewController.m
//  Places
//
//  Created by Iris Fu on 7/7/22.
//

#import "SignUpViewController.h"
#import "SceneDelegate.h"
@import Parse;


@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)didTapSignUp:(id)sender;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            
            // display view controller that needs to shown after successful sign up
            SceneDelegate *sceneDelegate = self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            sceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        }
    }];
}

- (IBAction)didTapSignUp:(id)sender {
    [self registerUser];
}

@end
