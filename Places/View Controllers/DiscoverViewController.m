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
@property (nonatomic, strong) NSArray *placesToDisplay;
@property (nonatomic) BOOL *sortByIncreasingFavorites;
@property (nonatomic) BOOL *sortByDecreasingFavorites;
- (IBAction)didTapSortByIncreasingFavorites:(id)sender;
- (IBAction)didTapSortByDecreasingFavorites:(id)sender;

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


// sort self.places to be an array that starts from most favorited to least favorited
- (void)sortResultsByIncreasingFavorites {
//    NSMutableArray *searchResultPlaceIDs = [[NSMutableArray alloc] init];
//    for (NSDictionary *googlePlace in self.places) {
//        [searchResultPlaceIDs addObject:googlePlace[@"place_id"]];
//    }
//    NSLog(@"Got searchResultPlaceIDs %@", searchResultPlaceIDs);
//
//    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
//    [query whereKey:@"place_id" containsAllObjectsInArray:searchResultPlaceIDs];
//    [query orderByDescending:@"favoriteCount"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *sortedPlaceParseObjects, NSError *error) {
//      if (!error) {
//        NSLog(<#NSString * _Nonnull format, ...#>)
//      } else {
//        // Log details of the failure
//        NSLog(@"Error: %@ %@", error, [error userInfo]);
//      }
//    }];
    
//    NSMutableDictionary *placesToFavoriteCount = [[NSMutableDictionary alloc] init];
//
//    // set placesToFavoriteCount
//    for (NSDictionary *googlePlace in self.places) {
//        PFQuery *query = [PFQuery queryWithClassName:@"Place"];
//        [query whereKey:@"placeID" equalTo:googlePlace[@"place_id"]];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *parsePlaceObjects, NSError *error) {
//            if (error) {
//                NSLog(@"Got an error while fetching place from Parse");
//            } else {
//                if ([parsePlaceObjects count] == 1) {
//                    Place *parsePlaceObject = parsePlaceObjects[0];
//                    NSLog(@"Got a Parse Place Object for %@ with favorite count %@", parsePlaceObject[@"name"], parsePlaceObject[@"favoriteCount"]);
//                    [placesToFavoriteCount setObject:parsePlaceObject[@"favoriteCount"] forKey:googlePlace[@"place_id"]];
//                    NSLog(@"Should have added key value pair to placesToFavoriteCount %@", placesToFavoriteCount);
//                }
//            }
//        }];
//    }
//
//    NSLog(@"The placesToFavoriteCount dictionary has been set and is %@", placesToFavoriteCount);
//
//    // set self.places to be sorted from most to least favorited
//    self.places = [placesToFavoriteCount keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 compare:obj2];
//    }];
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
               NSArray *resultsAsGooglePlaceObjects = dataDictionary[@"results"];
               for (NSDictionary *googlePlaceObject in resultsAsGooglePlaceObjects) {
                  [self createNewPlaceModelInParseIfNecessary:googlePlaceObject];
               }
               
               // set self.placesToDisplay as Parse object version of resultsAsGooglePlaceObjects
               NSMutableArray *searchResultPlaceIDs = [[NSMutableArray alloc] init];
               for (NSDictionary *googlePlace in resultsAsGooglePlaceObjects) {
                   [searchResultPlaceIDs addObject:googlePlace[@"place_id"]];
               }
               NSLog(@"Got searchResultPlaceIDs %@", searchResultPlaceIDs);

               PFQuery *query = [PFQuery queryWithClassName:@"Place"];
               [query whereKey:@"placeID" containedIn:searchResultPlaceIDs];
//               [query orderByDescending:@"favoriteCount"];
               [query findObjectsInBackgroundWithBlock:^(NSArray *parsePlaceObjects, NSError *error) {
                 if (!error) {
                     self.placesToDisplay = parsePlaceObjects;
                     NSLog(@"self.placesToDisplay is now has %lu elements", (unsigned long)[self.placesToDisplay count]);
                     [self.searchResults reloadData];
                 } else {
                   // Log details of the failure
                   NSLog(@"Error: %@ %@", error, [error userInfo]);
                 }
               }];
           }
       }];
    [task resume];
}

- (void) loadDefaultPlacesToDisplay {
    [self fetchPlaces:@"to do"];
    NSLog(@"self.placesToDisplay in loadDefaultPlacesToDisplay has %lu elements", [self.placesToDisplay count]);
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

- (void)setAttributesOfPlaceCell:(Place *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    placeTableViewCell.placeName.text = place[@"name"];
    placeTableViewCell.placeRatings.text = [NSString stringWithFormat:@"%@ out of 5 stars", place[@"rating"]];
    placeTableViewCell.placeAddress.text = place[@"address"];
    placeTableViewCell.placeFavoriteCount.text = [NSString stringWithFormat:@"Favorited by %@ other users", place[@"favoriteCount"]];
    
    // get first photo to display
    NSString *firstPhotoReference = ((place[@"photos"])[0])[@"photo_reference"];
    NSLog(@"This is the first photo's reference: %@", firstPhotoReference);
    NSString *requestURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", firstPhotoReference];
    [placeTableViewCell.placeImage setImageWithURL:[NSURL URLWithString:requestURLString]];
    
    // Configure addToFavorites button
    PFUser *currentUser = [PFUser currentUser];
    
    if ([self notFavoritedBy:currentUser forPlaceID:place[@"placeID"]]) {
        [placeTableViewCell.addToFavoritesButton setTitle:@" Add to Favorites" forState:UIControlStateNormal];
        [placeTableViewCell.addToFavoritesButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
    } else {
        [placeTableViewCell.addToFavoritesButton setTitle:@" Added to Favorites" forState:UIControlStateNormal];
        [placeTableViewCell.addToFavoritesButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaceTableViewCell *placeTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    Place *parsePlace = self.placesToDisplay[indexPath.row];
    
    [self setAttributesOfPlaceCell:parsePlace placeTableViewCell:placeTableViewCell];
    placeTableViewCell.place = parsePlace;
    
    return placeTableViewCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placesToDisplay.count;
}


- (IBAction)didTapSortByDecreasingFavorites:(id)sender {

}

- (IBAction)didTapSortByIncreasingFavorites:(id)sender {
    // if sortByIncreasingFavorites:
        // change button style to filled
        // reload current results to be sorted by increasing order
        // ensure future results will be sorted by increasing order
    // else
        // change button style to gray
}
@end
