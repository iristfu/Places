//
//  DiscoverViewController.m
//  Places
//
//  Created by Iris Fu on 7/10/22.
//

#import "DiscoverViewController.h"
#import "GooglePlaces/GMSPlace.h"
#import "PlaceTableViewCell.h"
#import "GooglePlaces/GMSPlaceFieldMask.h"
#import "UIImageView+AFNetworking.h"
#import "Place.h"
@import GooglePlaces;
@import Parse;

@interface DiscoverViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *places;

@end

@implementation DiscoverViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.searchResults.dataSource = self;
    self.searchResults.delegate = self;
    self.searchResults.rowHeight = UITableViewAutomaticDimension;
    
    [self loadDefaultPlacesToDisplay];
}

- (void)fetchPlaces:(NSString *)query {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    NSString *formattedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    NSLog(@"formattedQuery: %@", formattedQuery);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", formattedQuery]];
    NSLog(@"the url: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               // TODO: can implement [self showAlertError];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.places = dataDictionary[@"results"];
               NSLog(@"%@", self.places);
               [self.searchResults reloadData];
           }
       }];
    [task resume];
    
}

- (void) loadDefaultPlacesToDisplay {
    [self fetchPlaces:@"to do"];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length != 0) {
        [self fetchPlaces:searchBar.text];
    }
    [self.searchBar resignFirstResponder];
    [self.searchResults reloadData];
}

- (void)createNewPlaceModelInParseIfNecessary:(NSDictionary *)place {
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"placeID" equalTo:place[@"place_id"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *places, NSError *error) {
        if (error) {
            NSLog(@"Got an error while fetching places");
        } else {
            if ([places count] == 0) {
                Place *newPlace = [Place new];
                newPlace.placeID = place[@"place_id"];
                newPlace.name = place[@"name"];
                newPlace.address = place[@"formatted_address"];
                newPlace.photos = place[@"photos"];
                newPlace.rating = place[@"rating"];
                newPlace.categories = place[@"types"];
                newPlace.lat = place[@"geometry"][@"location"][@"lat"];
                newPlace.lng = place[@"geometry"][@"location"][@"lng"];
                newPlace.favoriteCount = 0;
                [newPlace saveInBackground];
                NSLog(@"Created new Place model for %@", place[@"name"]);
            }
        }
    }];
}

- (bool)notFavoritedBy:(PFUser *)currentUser forPlaceID:(NSString *) placeID {
    return ![currentUser[@"favoritedPlaces"] containsObject:placeID];
}

- (void)setAttributesOfPlaceCell:(NSDictionary *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    placeTableViewCell.placeName.text = place[@"name"];
    placeTableViewCell.placeRatings.text = [NSString stringWithFormat:@"%@ out of 5 stars", place[@"rating"]];
    placeTableViewCell.placeAddress.text = place[@"formatted_address"];
    placeTableViewCell.placeFavoriteCount.text = [NSString stringWithFormat:@"Favorited by %@ other users", @"x"]; // Can replace x in the future
    
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaceTableViewCell *placeTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    NSDictionary *place = self.places[indexPath.row];

    [self createNewPlaceModelInParseIfNecessary:place];
    [self setAttributesOfPlaceCell:place placeTableViewCell:placeTableViewCell];
    placeTableViewCell.place = place;
    
    return placeTableViewCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}


@end
