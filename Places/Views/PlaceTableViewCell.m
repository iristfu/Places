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

- (bool)notFavoritedBy:(PFUser *)currentUser {
    return ![currentUser[@"favoritedPlaces"] containsObject:self.place[@"place_id"]];
}

- (IBAction)didTapAddToFavorites:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    
    // Increase the Places’s favorite count in the Parse Place model
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"placeID" equalTo:self.place[@"place_id"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *places, NSError *error) {
        if (error) {
            NSLog(@"Got error getting place in didTapAddToFavorites");
        } else {
            if ([places count] != 1) {
                NSLog(@"Could not find place for place_id to increment favoriteCount");
            } else {
                if ([self notFavoritedBy:currentUser]) {
                    NSLog(@"Place not favorited by current user");
                    [currentUser addObject:self.place[@"place_id"] forKey:@"favoritedPlaces"];
                    [currentUser saveInBackground];
                    NSLog(@"The user's favoritedPlaces array is now: %@", currentUser[@"favoritedPlaces"]);
                    
                    [places[0] incrementKey:@"favoriteCount"];
                    [places[0] saveInBackground];
                    NSLog(@"Incremented favorite count for %@", places[0][@"name"]);
                } else {
                    NSLog(@"%@ already favorited by user", places[0][@"name"]);
                }
            }
        }
    }];
}

@end
