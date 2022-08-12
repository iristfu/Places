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
@property (strong, nonatomic) IBOutlet UIButton *editProfilePictureButton;
- (IBAction)didTapEditProfilePictureButton:(id)sender;


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
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height / 2;
    self.profilePicture.layer.masksToBounds = YES;
    self.profilePicture.layer.borderWidth = 0;
    self.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
    
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

- (IBAction)didTapEditProfilePictureButton:(id)sender {
    [self renderImagePicker];
}

-(void)renderImagePicker {
    // set up image picker
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = true;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    if (editedImage) {
        [self.profilePicture setImage:editedImage];
    } else {
        [self.profilePicture setImage:originalImage];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        CGSize size = CGSizeMake(300, 300);
        UIImage *uploadImage = [self resizeImage:self.profilePicture.image withSize:size];
        currentUser[@"profilePicture"] = [self getPFFileFromImage:uploadImage];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"Error changing profile picture");
            }
        }];
    }
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


@end
