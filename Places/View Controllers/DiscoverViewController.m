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

//- (id)init {
//    self = [super init];
//    self.placesInParse = [[NSMutableDictionary alloc] init];
//    return self;
//}

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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaceTableViewCell *placeTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    NSDictionary *place = self.places[indexPath.row];
    NSLog(@"Current place: %@", place);
    placeTableViewCell.placeName.text = place[@"name"];
    placeTableViewCell.placeRatings.text = [NSString stringWithFormat:@"%@ out of 5 stars", place[@"rating"]];
    placeTableViewCell.placeAddress.text = place[@"formatted_address"];

    // get first photo to display
    NSString *firstPhotoReference = ((place[@"photos"])[0])[@"photo_reference"];
    NSLog(@"This is the first photo's reference: %@", firstPhotoReference);
    NSString *requestURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", firstPhotoReference];
    [placeTableViewCell.placeImage setImageWithURL:[NSURL URLWithString:requestURLString]];
    
    placeTableViewCell.place = place;
    
    // Create new Place object in Parse if it doesn't already exist
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
                newPlace.lng = place[@"geometry"][@"location"][@"lat"];
                [newPlace saveInBackground];
                NSLog(@"Created new Place model for %@", place[@"name"]);
            }
        }
    }];
    
    return placeTableViewCell;
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}


@end
