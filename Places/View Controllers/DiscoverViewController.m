//
//  DiscoverViewController.m
//  Places
//
//  Created by Iris Fu on 7/10/22.
//

#import "DiscoverViewController.h"
#import "GooglePlaces/GMSPlace.h"
#import "PlaceTableViewCell.h"

@interface DiscoverViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *places;

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    
    self.searchResults.dataSource = self;
    self.searchResults.delegate = self;
    
    [self loadDefaultPlacesToDisplay];
}

- (void) loadDefaultPlacesToDisplay {
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=to%20do&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE"];
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

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  // Update the GMSAutocompleteTableDataSource with the search text.
//  [tableDataSource sourceTextHasChanged:searchText];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaceTableViewCell *placeTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
//    // TODO: Get specific place using a for loop and replace the following code
//    placeTableViewCell.placeName.text = @"placeHolderPlaceName";
//    placeTableViewCell.placeAddress.text = @"1234 Hacker Way, The Metaverse";
//    placeTableViewCell.placeRatings.text = @"****";
    // set image here
    
    NSDictionary *place = self.places[indexPath.row];
    NSLog(@"Current place: %@", place);
    placeTableViewCell.placeName.text = place[@"name"];
    return placeTableViewCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}


@end
