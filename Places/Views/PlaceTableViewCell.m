//
//  PlaceTableViewCell.m
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import "PlaceTableViewCell.h"
#import "Place.h"
#import "UIImageView+AFNetworking.h"
#import "DiscoverViewController.h"
@import Parse;

@implementation PlaceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.place.fetchIfNeeded;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (bool)notFavoritedBy:(PFUser *)currentUser {
    return ![currentUser[@"favoritedPlaces"] containsObject:self.place[@"placeID"]];
}

- (void)handleAddToFavoriteButtonFunctionalities {
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
//        [self.addToButton setTitle:@" Added to Favorites" forState:UIControlStateNormal];
        [UIView transitionWithView:self.addToButton
                          duration:0.25f
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        animations:^{
            [self.addToButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
            self.addToButton.tintColor = [UIColor redColor];
          } completion:nil];

        // Update favorite count label
        [UIView transitionWithView:self.placeFavoriteCount
                          duration:0.25f
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        animations:^{
            self.placeFavoriteCount.text = [NSString stringWithFormat:@"❤️ %@", self.place[@"favoriteCount"]];
          } completion:nil];
    } else {
        NSLog(@"%@ already favorited by user", self.place[@"name"]);
    }
}

- (void)handleAddToPlacesToGoButtonFunctionalities {
    if (![self.delegate placeIsInPlacesToGoToAdd:self.place]) {
        [self.delegate addPlaceToPlacesToGoToAdd:self.place];
        
        // change the UI

        [UIView transitionWithView:self.addToButton
                          duration:0.25f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
            [self.addToButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
          } completion:nil];
        
    } else {
        NSLog(@"%@ is already in places to go", self.place[@"name"]);
    }
}

- (IBAction)didTapAddToButton:(id)sender {
    if ([self.viewFrom isEqualToString:@"ComposeView"]) {
        [self handleAddToPlacesToGoButtonFunctionalities];
    } else {
        [self handleAddToFavoriteButtonFunctionalities];
        
    }
}
@end
