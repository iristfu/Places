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

@interface DiscoverViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, PlaceTableViewCellDelegate>
@property (nonatomic, strong) NSArray *placesToDisplay;
@property (nonatomic, strong) NSString *currentQuery;
@property (nonatomic) BOOL *sortByIncreasingFavorites;
@property (nonatomic) BOOL *sortByDecreasingFavorites;
- (IBAction)didTapSortByIncreasingFavorites:(id)sender;
- (IBAction)didTapSortByDecreasingFavorites:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *increasingFavoritesButton;
@property (weak, nonatomic) IBOutlet UIButton *decreasingFavoritesButton;
@property (nonatomic, strong) NSMutableArray *existingPlacesToGo; // array of Place objectIDs

// specific to places to go
- (IBAction)didTapCancel:(id)sender;
- (IBAction)didTapDone:(id)sender;


@end

@implementation DiscoverViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.searchResults.dataSource = self;
    self.searchResults.delegate = self;
    self.searchResults.rowHeight = UITableViewAutomaticDimension;
    self.placesToGoToAdd = [[NSMutableArray alloc] init];
    
    NSLog(@"Set self.delegate to be %@ and self.viewFrom to be %@", self.delegate, self.viewFrom);
    // Change UI if triggered from compose view
    if ([self.viewFrom isEqualToString:@"ComposeView"]) {
        self.navigationItem.title = @"Add places to go";
    } else {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    self.existingPlacesToGo = [[NSMutableArray alloc] init];
    for (Place *place in [self.delegate getCurrentItinerary].placesToGo) {
        NSLog(@"Entered current places to go for loop");
        [self.existingPlacesToGo addObject:place.objectId];
    }
    NSLog(@"The existing places to go is %@", self.existingPlacesToGo);
    
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
               NSArray *resultsAsGooglePlaceObjects = dataDictionary[@"results"];
               NSMutableArray *searchResultPlaceIDs = [[NSMutableArray alloc] init];
               
               for (NSDictionary *googlePlaceObject in resultsAsGooglePlaceObjects) {
                   [self createNewPlaceModelInParseIfNecessary:googlePlaceObject];
                   [searchResultPlaceIDs addObject:googlePlaceObject[@"place_id"]];
               }
               NSLog(@"Got searchResultPlaceIDs %@", searchResultPlaceIDs);
               
               // QUESTION: How to wait until the above, specifically createNewPlaceModelInParseIfNecessary, finishes before moving on?
               // Currently getting a bug here due to asynchronous methods running, in the scenario where no Parse Place model has been created for
               // a place yet and the query to fetch the corresponding place gets called
               
               // set self.placesToDisplay as Parse object version of resultsAsGooglePlaceObjects
               PFQuery *query = [PFQuery queryWithClassName:@"Place"];
               [query whereKey:@"placeID" containedIn:searchResultPlaceIDs];
               
               if (self.sortByIncreasingFavorites) { // from most favorited to least favorited
                   NSLog(@"sortByIncreasingFavorites is true and filtering query accordingly");
                   [query orderByAscending:@"favoriteCount"];
               } else if (self.sortByDecreasingFavorites) {
                   NSLog(@"sortByDecreasingFavorites is true and filtering query accordingly");
                   [query orderByDescending:@"favoriteCount"];
               }
               
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
    self.currentQuery = @"to do";
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
        self.currentQuery = searchBar.text;
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

- (void)displayFirstPhotoOf:(Place *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    NSString *firstPhotoReference = ((place[@"photos"])[0])[@"photo_reference"];
    NSLog(@"This is the first photo's reference: %@", firstPhotoReference);
    NSString *requestURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", firstPhotoReference];
    [placeTableViewCell.placeImage setImageWithURL:[NSURL URLWithString:requestURLString]];
    placeTableViewCell.placeImage.layer.cornerRadius = placeTableViewCell.placeImage.frame.size.height / 16;
    placeTableViewCell.placeImage.layer.masksToBounds = YES;
    placeTableViewCell.placeImage.layer.borderWidth = 0;
    placeTableViewCell.placeImage.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)configureAddToButton:(Place *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    if ([self.viewFrom isEqualToString:@"ComposeView"]) {
        placeTableViewCell.viewFrom = @"ComposeView";
        placeTableViewCell.delegate = self;
        
        if (![self.existingPlacesToGo containsObject:place.objectId]) {
//            [placeTableViewCell.addToButton setTitle:@" Add to places to go" forState:UIControlStateNormal];
            [placeTableViewCell.addToButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        } else {
//            [placeTableViewCell.addToButton setTitle:@" Going" forState:UIControlStateNormal];
            [placeTableViewCell.addToButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
        }
        
    } else {
        PFUser *currentUser = [PFUser currentUser];
        if ([self notFavoritedBy:currentUser forPlaceID:place[@"placeID"]]) {
            [placeTableViewCell.addToButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        } else {
            [placeTableViewCell.addToButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
            placeTableViewCell.addToButton.tintColor = [UIColor redColor];
        }
    }
}

- (void)setAttributesOfPlaceCell:(Place *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    placeTableViewCell.placeName.text = place[@"name"];
    placeTableViewCell.placeRatings.text = [NSString stringWithFormat:@"⭐️ %@", place[@"rating"]];
    placeTableViewCell.placeAddress.text = place[@"address"];
    placeTableViewCell.placeFavoriteCount.text = [NSString stringWithFormat:@"❤️ %@", place[@"favoriteCount"] ? place[@"favoriteCount"] : @"0"];
    [self displayFirstPhotoOf:place placeTableViewCell:placeTableViewCell];
    [self configureAddToButton:place placeTableViewCell:placeTableViewCell];
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


- (void)setIncreasingFavoriteButtonToSelected {
    [self.increasingFavoritesButton setConfiguration:[UIButtonConfiguration filledButtonConfiguration]];
    [self.increasingFavoritesButton setTitle:@"Favorited" forState:UIControlStateNormal];
    [self.increasingFavoritesButton setImage:[UIImage systemImageNamed:@"arrow.up"] forState:UIControlStateNormal];
}

- (void)setIncreasingFavoriteButtonToDeselected {
    [self.increasingFavoritesButton setConfiguration:[UIButtonConfiguration grayButtonConfiguration]];
    [self.increasingFavoritesButton setTitle:@"Favorited" forState:UIControlStateNormal];
    [self.increasingFavoritesButton setImage:[UIImage systemImageNamed:@"arrow.up"] forState:UIControlStateNormal];
}

- (void)setDecreasingFavoriteButtonToDeselected {
    [self.decreasingFavoritesButton setConfiguration:[UIButtonConfiguration grayButtonConfiguration]];
    [self.decreasingFavoritesButton setTitle:@"Favorited" forState:UIControlStateNormal];
    [self.decreasingFavoritesButton setImage:[UIImage systemImageNamed:@"arrow.down"] forState:UIControlStateNormal];
}

- (void)setDecreasingFavoriteButtonToSelected {
    [self.decreasingFavoritesButton setConfiguration:[UIButtonConfiguration filledButtonConfiguration]];
    [self.decreasingFavoritesButton setTitle:@"Favorited" forState:UIControlStateNormal];
    [self.decreasingFavoritesButton setImage:[UIImage systemImageNamed:@"arrow.down"] forState:UIControlStateNormal];
}

- (IBAction)didTapSortByDecreasingFavorites:(id)sender {
    if (!self.sortByDecreasingFavorites) {
        // Change button UI
        [self setDecreasingFavoriteButtonToSelected];
        self.sortByDecreasingFavorites = YES;
    } else {
        // Change button UI
        [self setDecreasingFavoriteButtonToDeselected];
        self.sortByDecreasingFavorites = NO;
    }
    // reset increasing button UI and effect
    [self setIncreasingFavoriteButtonToDeselected];
    self.sortByIncreasingFavorites = NO;
    
    // refresh results
    [self fetchPlaces:self.currentQuery];
}


- (IBAction)didTapSortByIncreasingFavorites:(id)sender {
    if (!self.sortByIncreasingFavorites) {
        // Change button UI
        [self setIncreasingFavoriteButtonToSelected];
        // Change search results
        self.sortByIncreasingFavorites = YES;
    } else {
        // Change button UI
        [self setIncreasingFavoriteButtonToDeselected];
        // Change search results
        self.sortByIncreasingFavorites = NO;
    }
    // reset decreasing button UI and effect
    [self setDecreasingFavoriteButtonToDeselected];
    self.sortByDecreasingFavorites = NO;
    
    // refresh results
    [self fetchPlaces:self.currentQuery];
}

- (IBAction)didTapDone:(id)sender {
    [self.delegate finishedAddingPlacesToGo:self.placesToGoToAdd];
    NSLog(@"Passed the places to go array %@ to compose view itinerary", self.placesToGoToAdd);
    [self dismissViewControllerAnimated:true completion:nil];
}


- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - PlaceTableViewCellDelegate

- (void)addPlaceToPlacesToGoToAdd:(nonnull Place *)place {
    [self.placesToGoToAdd addObject:place];
    NSLog(@"self.placesToGoToAdd is now %@", self.placesToGoToAdd);
}

- (BOOL)placeIsInPlacesToGoToAdd:(nonnull Place *)place {
    NSLog(@"returning %d that self.placesToGo contains the place %@", [self.placesToGoToAdd containsObject:place], place);
    return [self.placesToGoToAdd containsObject:place];
}


@end
