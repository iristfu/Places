//
//  DiscoverViewController.m
//  Places
//
//  Created by Iris Fu on 7/10/22.
//

#import "DiscoverViewController.h"
#import "GooglePlaces/GMSPlace.h"
#import "GooglePlaces/GMSAutocompleteResultsViewController.h"
#import "GooglePlaces/GMSAutocompleteTableDataSource.h"

@interface DiscoverViewController () <GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate>

@end

@implementation DiscoverViewController {
    // QUESTION: What does this code do? Iniaitlize variables that will be used across functions
//    UITableView *tableView;
    GMSAutocompleteTableDataSource *tableDataSource;
}

- (void)viewDidLoad {
  [super viewDidLoad];

//  UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
  self.searchBar.delegate = self;

  [self.view addSubview:self.searchBar];

  tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
  tableDataSource.delegate = self;

//  tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 44)];
  self.searchResults.delegate = tableDataSource;
  self.searchResults.dataSource = tableDataSource;

  [self.view addSubview:self.searchResults];
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate

- (void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
  // Turn the network activity indicator off.
  UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;

  // Reload table data.
  [self.searchResults reloadData];
}

- (void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
  // Turn the network activity indicator on.
  UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;

  // Reload table data.
  [self.searchResults reloadData];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
  // Do something with the selected place.
  NSLog(@"Place name: %@", place.name);
  NSLog(@"Place address: %@", place.formattedAddress);
  NSLog(@"Place attributions: %@", place.attributions);
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didFailAutocompleteWithError:(NSError *)error {
  // Handle the error
  NSLog(@"Error %@", error.description);
}

- (BOOL)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didSelectPrediction:(GMSAutocompletePrediction *)prediction {
  return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  // Update the GMSAutocompleteTableDataSource with the search text.
  [tableDataSource sourceTextHasChanged:searchText];
}

//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    GMSAutocompleteResultsViewController _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
//    _resultsViewController.delegate = self;
//
//    UISearchController *_searchController = [[UISearchController alloc]
//                             initWithSearchResultsController:_resultsViewController];
//    _searchController.searchResultsUpdater = _resultsViewController;
//
//    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 65.0, 250, 50)];
//
//    [subView addSubview:_searchController.searchBar];
//    [_searchController.searchBar sizeToFit];
//    [self.view addSubview:subView];
//
//    // When UISearchController presents the results view, present it in
//    // this view controller, not one further up the chain.
//    self.definesPresentationContext = YES;
//}
//
//// Handle the user's selection.
//- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
//didAutocompleteWithPlace:(GMSPlace *)place {
//  [self dismissViewControllerAnimated:YES completion:nil];
//  // Do something with the selected place.
//  NSLog(@"Place name %@", place.name);
//  NSLog(@"Place address %@", place.formattedAddress);
//  NSLog(@"Place attributions %@", place.attributions.string);
//}
//
//- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
//didFailAutocompleteWithError:(NSError *)error {
//  [self dismissViewControllerAnimated:YES completion:nil];
//  // TODO: handle the error.
//  NSLog(@"Error: %@", [error description]);
//}



@end
