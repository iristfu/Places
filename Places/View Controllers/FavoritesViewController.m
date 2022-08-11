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
@property (nonatomic, strong) NSMutableArray *favoritedPlaces;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Favorites";
    
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
    self.favoritedPlaces = [[[currentUser[@"favoritedPlaces"] mutableCopy] reverseObjectEnumerator] allObjects];
    NSLog(@"The current user's favorited places are %@", self.favoritedPlaces); // an array of place IDs
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
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
    placeTableViewCell.placeRatings.text = [NSString stringWithFormat:@"⭐️ %@", place[@"rating"]];
    placeTableViewCell.placeAddress.text = place[@"address"];
    NSLog(@"The formatted addres is %@", place[@"address"]);
    placeTableViewCell.placeFavoriteCount.text = [NSString stringWithFormat:@"❤️ %@", place[@"favoriteCount"]];
    
    // get first photo to display
    NSString *firstPhotoReference = ((place[@"photos"])[0])[@"photo_reference"];
    NSLog(@"This is the first photo's reference: %@", firstPhotoReference);
    NSString *requestURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", firstPhotoReference];
    [placeTableViewCell.placeImage setImageWithURL:[NSURL URLWithString:requestURLString]];
    placeTableViewCell.placeImage.layer.cornerRadius = placeTableViewCell.placeImage.frame.size.height / 16;
    placeTableViewCell.placeImage.layer.masksToBounds = YES;
    placeTableViewCell.placeImage.layer.borderWidth = 0;
    placeTableViewCell.placeImage.contentMode = UIViewContentModeScaleAspectFill;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoritedPlaces.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   if (editingStyle == UITableViewCellEditingStyleDelete) {
       PFUser *currentUser = [PFUser currentUser];
       NSString *placeIDToUnfavorite = [self.favoritedPlaces objectAtIndex:[indexPath row]];

       // decrement favorite count for place
       PFQuery *query = [PFQuery queryWithClassName:@"Place"];
       [query whereKey:@"placeID" equalTo:placeIDToUnfavorite];
       [query findObjectsInBackgroundWithBlock:^(NSArray *places, NSError *error) {
           if (error) {
               NSLog(@"Got an error while fetching place to unfavorite");
           } else {
               if ([places count] == 1) {
                   Place *placeToUnfavorite = places[0];
                   [placeToUnfavorite incrementKey:@"favoriteCount" byAmount:[NSNumber numberWithInt:-1]];
                   [placeToUnfavorite saveInBackground];
               }
           }
       }];
       
       [self.favoritedPlaces removeObject:placeIDToUnfavorite];
       [currentUser[@"favoritedPlaces"] removeObject:placeIDToUnfavorite];
       [currentUser saveInBackground];
       
       [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
   }
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleNone;
//}
//
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSString *favoritedPlaceID = [self.favoritedPlaces objectAtIndex:fromIndexPath.row];
    [self.favoritedPlaces removeObjectAtIndex:fromIndexPath.row];
    [self.favoritedPlaces insertObject:favoritedPlaceID atIndex:toIndexPath.row];
}


@end
