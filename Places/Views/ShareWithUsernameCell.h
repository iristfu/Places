//
//  ShareWithUsernameCell.h
//  Places
//
//  Created by Iris Fu on 8/4/22.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ShareWithUsernameCell : UITableViewCell
- (IBAction)didTapShare:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) PFUser *user;
@end

NS_ASSUME_NONNULL_END
