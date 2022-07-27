//
//  SignUpViewController.h
//  Places
//
//  Created by Iris Fu on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SignUpViewControllerDelegate
- (void)userDidSignUp;
@end

@interface SignUpViewController : UIViewController

@property (nonatomic, weak) id<SignUpViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
