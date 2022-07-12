//
//  PlaceTableViewCell.m
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import "PlaceTableViewCell.h"
@import Parse;

@implementation PlaceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapAddToFavorites:(id)sender {
    NSLog(@"didTapAddToFavorites called");
    
    // Increase the Places’s favorite count in the Parse Place model
    
    // Add the place to the the current User's favorites list
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addObject:self.placeID forKey:@"favoritedPlaces"];
    [currentUser saveInBackground];
    NSLog(@"The user's favoritedPlaces array is now: %@", currentUser[@"favoritedPlaces"]);
}
@end
