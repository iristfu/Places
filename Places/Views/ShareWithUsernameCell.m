//
//  ShareWithUsernameCell.m
//  Places
//
//  Created by Iris Fu on 8/4/22.
//

#import "ShareWithUsernameCell.h"

@implementation ShareWithUsernameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    NSLog(@"self.username in awakeFromNib is %@", self.username);
//    self.usernameLabel.text = self.username;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapShare:(id)sender {
    NSLog(@"tapped share on %@", self.user.username);
}

@end
