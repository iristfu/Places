//
//  ShareWithUsernameCell.h
//  Places
//
//  Created by Iris Fu on 8/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareWithUsernameCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *username;
- (IBAction)didTapShare:(id)sender;

@end

NS_ASSUME_NONNULL_END
