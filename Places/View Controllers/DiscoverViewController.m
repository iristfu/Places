//
//  DiscoverViewController.m
//  Places
//
//  Created by Iris Fu on 7/10/22.
//

#import "DiscoverViewController.h"
#import "GooglePlaces/GMSPlace.h"
#import "GooglePlaces/GMSAutocompleteResultsViewController.h"

@interface DiscoverViewController ()

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSAutocompleteResultsViewController *_resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _resultsViewController.delegate = self;

    UISearchController *_searchController = [[UISearchController alloc]
                             initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;

    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 65.0, 250, 50)];

    [subView addSubview:_searchController.searchBar];
    [_searchController.searchBar sizeToFit];
    [self.view addSubview:subView];

    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    self.definesPresentationContext = YES;
}

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didAutocompleteWithPlace:(GMSPlace *)place {
  [self dismissViewControllerAnimated:YES completion:nil];
  // Do something with the selected place.
  NSLog(@"Place name %@", place.name);
  NSLog(@"Place address %@", place.formattedAddress);
  NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
  // TODO: handle the error.
  NSLog(@"Error: %@", [error description]);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
