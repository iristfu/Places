//
//  PlaceTableViewCell.m
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import "PlaceTableViewCell.h"
#import "Place.h"
#import "UIImageView+AFNetworking.h"
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

- (bool)notFavoritedBy:(PFUser *)currentUser {
    return ![currentUser[@"favoritedPlaces"] containsObject:self.place[@"placeID"]];
}

- (IBAction)didTapAddToButton:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    if ([self notFavoritedBy:currentUser]) {
        // Add to user's favoritedPlaces array
        [currentUser addObject:self.place[@"placeID"] forKey:@"favoritedPlaces"];
        [currentUser saveInBackground];
        NSLog(@"The user's favoritedPlaces array is now: %@", currentUser[@"favoritedPlaces"]);
        
        // Increment Place's favorite count
        [self.place incrementKey:@"favoriteCount"];
        [self.place saveInBackground];
        NSLog(@"Incremented favorite count for %@", self.place[@"name"]);
        
        // Change button UI
        [self.addToButton setTitle:@" Added to Favorites" forState:UIControlStateNormal];
        [self.addToButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
        
        // Update favorite count label
        self.placeFavoriteCount.text = [NSString stringWithFormat:@"Favorited by %@ other users", self.place[@"favoriteCount"]];
    } else {
        NSLog(@"%@ already favorited by user", self.place[@"name"]);
    }
}
@end
