//
//  PlaceTableViewCell.m
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import "PlaceTableViewCell.h"
#import "Place.h"
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
//    if (
//    Place *placeToFavorite = [Place new];
//    placeToFavorite.placeID = self.place[@"place_id"];
    
    // Add the place to the the current User's favorites list
    PFUser *currentUser = [PFUser currentUser];
    if (![currentUser[@"favoritedPlaces"] containsObject:self.place[@"place_id"]]) {
        [currentUser addObject:self.place[@"place_id"] forKey:@"favoritedPlaces"];
        [currentUser saveInBackground];
    }
    NSLog(@"The user's favoritedPlaces array is now: %@", currentUser[@"favoritedPlaces"]);
}
@end
