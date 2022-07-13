//
//  FavoritesViewController.m
//  Places
//
//  Created by Iris Fu on 7/12/22.
//

#import "FavoritesViewController.h"
#import "PlaceTableViewCell.h"
#import "UIImageView+AFNetworking.h"
@import Parse;

@interface FavoritesViewController ()
@property (nonatomic, strong) NSArray *favoritedPlaces;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadFavoritedPlaces) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadFavoritedPlaces];
}

- (void)loadFavoritedPlaces {
    PFUser *currentUser = [PFUser currentUser];
    self.favoritedPlaces = [[currentUser[@"favoritedPlaces"] reverseObjectEnumerator] allObjects];
    NSLog(@"The current user's favorited places are %@", self.favoritedPlaces); // an array of place IDs
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaceTableViewCell *placeCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    NSString *placeID = self.favoritedPlaces[indexPath.row];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"placeID" equalTo:placeID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *places, NSError *error) {
        if (error) {
            NSLog(@"Got an error while fetching places");
        } else {
            if ([places count] == 1) {
                NSDictionary *place = places[0];
                [self setAttributesOfPlaceCell:place placeTableViewCell:placeCell];
            }
        }
    }];

    return placeCell;
}

- (bool)notFavoritedBy:(PFUser *)currentUser forPlaceID:(NSString *) placeID {
    return ![currentUser[@"favoritedPlaces"] containsObject:placeID];
}

- (void)setAttributesOfPlaceCell:(NSDictionary *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    placeTableViewCell.placeName.text = place[@"name"];
    placeTableViewCell.placeRatings.text = [NSString stringWithFormat:@"%@ out of 5 stars", place[@"rating"]];
    placeTableViewCell.placeAddress.text = place[@"address"];
    NSLog(@"The formatted addres is %@", place[@"address"]);
    placeTableViewCell.placeFavoriteCount.text = [NSString stringWithFormat:@"Favorited by %@ other users", place[@"favoriteCount"]]; // Can replace x in the future
    
    // get first photo to display
    NSString *firstPhotoReference = ((place[@"photos"])[0])[@"photo_reference"];
    NSLog(@"This is the first photo's reference: %@", firstPhotoReference);
    NSString *requestURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", firstPhotoReference];
    [placeTableViewCell.placeImage setImageWithURL:[NSURL URLWithString:requestURLString]];
    
    // Configure addToFavorites button
    PFUser *currentUser = [PFUser currentUser];
    
    if ([self notFavoritedBy:currentUser forPlaceID:place[@"place_id"]]) {
        [placeTableViewCell.addToFavoritesButton setTitle:@" Add to Favorites" forState:UIControlStateNormal];
        [placeTableViewCell.addToFavoritesButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
    } else {
        [placeTableViewCell.addToFavoritesButton setTitle:@" Added to Favorites" forState:UIControlStateNormal];
        [placeTableViewCell.addToFavoritesButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoritedPlaces.count;
}



@end
