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
    return ![currentUser[@"favoritedPlaces"] containsObject:self.place[@"place_id"]];
}

- (IBAction)didTapAddToFavorites:(id)sender {
    PFUser *currentUser = [PFUser currentUser];

    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"placeID" equalTo:self.place[@"place_id"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *places, NSError *error) {
        if (error) {
            NSLog(@"Got error getting place in didTapAddToFavorites");
        } else {
            if ([places count] != 1) {
                NSLog(@"Could not find place for place_id to increment favoriteCount");
            } else {
                Place *parsePlaceObject = places[0];
                if ([self notFavoritedBy:currentUser]) {
                    // Add to user's favoritedPlaces array
                    [currentUser addObject:self.place[@"place_id"] forKey:@"favoritedPlaces"];
                    [currentUser saveInBackground];
                    NSLog(@"The user's favoritedPlaces array is now: %@", currentUser[@"favoritedPlaces"]);
                    
                    // Increment Place's favorite count
                    [parsePlaceObject incrementKey:@"favoriteCount"];
                    [parsePlaceObject saveInBackground];
                    NSLog(@"Incremented favorite count for %@", parsePlaceObject[@"name"]);
                    
                    // Change button UI
                    [self.addToFavoritesButton setTitle:@" Added to Favorites" forState:UIControlStateNormal];
                    [self.addToFavoritesButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
                    
                    // Update favorite count label
                    self.placeFavoriteCount.text = [NSString stringWithFormat:@"Favorited by %@ other users", parsePlaceObject[@"favoriteCount"]];
                } else {
                    NSLog(@"%@ already favorited by user", parsePlaceObject[@"name"]);
                }
            }
        }
    }];
}
@end
