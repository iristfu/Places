//
//  LoginViewController.m
//  Places
//
//  Created by Iris Fu on 7/7/22.
//

#import "LoginViewController.h"
#import "SceneDelegate.h"
@import Parse;

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)didTapLogin:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *logo;

@end


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logo.image = [UIImage imageNamed:@"places_logo"];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}


- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            
            // call delegate after successful login
            self.delegate = self.view.window.windowScene.delegate;
            [self.delegate userDidLogin];
        }
    }];
}

- (IBAction)didTapLogin:(id)sender {
    [self loginUser];
}

@end
