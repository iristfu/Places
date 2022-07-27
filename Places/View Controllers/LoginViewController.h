//
//  LoginViewController.h
//  Places
//
//  Created by Iris Fu on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoginViewControllerDelegate 
- (void)userDidLogin;
@end

@interface LoginViewController : UIViewController

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
