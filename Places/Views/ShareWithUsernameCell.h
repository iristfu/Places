//
//  ShareWithUsernameCell.h
//  Places
//
//  Created by Iris Fu on 8/4/22.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol ShareWithUsernameCellDelegate

- (void)showAlert:(UIAlertController *)alert;

@end

@interface ShareWithUsernameCell : UITableViewCell
- (IBAction)didTapShare:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Itinerary *itinerary;
@property (strong, nonatomic) NSString *accessPermission;
@property (nonatomic, weak) id<ShareWithUsernameCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
