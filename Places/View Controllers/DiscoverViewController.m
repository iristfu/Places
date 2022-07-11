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
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  // Update the GMSAutocompleteTableDataSource with the search text.
//  [tableDataSource sourceTextHasChanged:searchText];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaceTableViewCell *placeTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    // TODO: Get specific place using a for loop and replace the following code
    placeTableViewCell.placeName.text = @"placeHolderPlaceName";
    placeTableViewCell.placePrice.text = @"$$";
    placeTableViewCell.placeRatings.text = @"****";
    // set image here
    return placeTableViewCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}


@end
