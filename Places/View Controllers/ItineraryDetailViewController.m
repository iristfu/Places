//
//  ItineraryDetailViewController.m
//  Places
//
//  Created by Iris Fu on 7/19/22.
//

#import "ItineraryDetailViewController.h"
#import "PlaceTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Place.h"
#import "ActivityHistoryViewController.h"
#import "ShortestRouteMapViewController.h"
#import "ComposeItineraryViewController.h"
#import "ShareItineraryViewController.h"

@interface ItineraryDetailViewController () <UITableViewDelegate, UITableViewDataSource, MapShortestRouteDelegate, EditItineraryViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *itineraryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itineraryDatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportationDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lodgingDetailsLabel;
@property (weak, nonatomic) IBOutlet UITableView *placesToGoTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editItineraryButton;

@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAccessPermission];
    
    
    self.mapLoadingIndicator.hidden = YES;
    self.mapLoadingIndicator.hidesWhenStopped = YES;
    
    self.itineraryNameLabel.text = self.itinerary[@"name"];
    self.itineraryDatesLabel.text = [NSString stringWithFormat:@"%@ - %@", self.itinerary[@"startDate"], self.itinerary[@"endDate"]];
    self.transportationDetailsLabel.text = self.itinerary[@"travelDetails"];
    self.lodgingDetailsLabel.text = self.itinerary[@"lodgingDetails"];
    
    self.placesToGoTableView.delegate = self;
    self.placesToGoTableView.dataSource = self;
    
    // update activity history for given itinerary
    Activity *newViewActivity = [Activity new];
    newViewActivity.activityType = @"Viewed";
    newViewActivity.user = [PFUser currentUser];
    newViewActivity.timestamp = [NSDate date];
    [newViewActivity save];
    self.itinerary.activityHistory = [self.itinerary.activityHistory arrayByAddingObject:newViewActivity];
    NSLog(@"Updated itinerary activity history: %@", self.itinerary.activityHistory);
    [self.itinerary saveInBackground];
}

- (NSArray<NSString *> *)getEditAccessUserObjectIDs {
    NSMutableArray *userObjectIDs = [[NSMutableArray alloc] init];
    for (PFUser *user in self.itinerary.usersWithEditAccess) {
        [userObjectIDs addObject:user.objectId];
    }
    return [userObjectIDs copy];
}

- (void)setAccessPermission {
    NSLog(@"Access permission for this itinerary is %@", self.accessPermission);
    
    if (!self.accessPermission) {
        // fetch access permission from Parse. If already set, then permisison was set in scene delegate and user got to this view via link
//        PFUser *currentUser = [PFUser currentUser];
//        if ([currentUser[@"viewOnlyItineraryIDs"] containsObject:self.itinerary.objectId]) {
//            self.accessPermission = @"view";
//        } else {
//            self.accessPermission = @"edit";
//        }
        NSLog(@"This is usersWithViewAccess %@", self.itinerary.usersWithViewAccess);
        NSLog(@"This is usersWithEditAccess %@", self.itinerary.usersWithEditAccess);
        NSLog(@"This is currentUser %@", [PFUser currentUser]);
        
        NSArray<NSString *> *editAccessUserObjectIDs = [self getEditAccessUserObjectIDs];
        
        if ([editAccessUserObjectIDs containsObject:[PFUser currentUser].objectId]) {
            self.accessPermission = @"edit";
        } else {
            self.accessPermission = @"view";
        }
    }
    if ([self.accessPermission isEqualToString:@"view"]) {
        // Remove edit button
        NSMutableArray *rightBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        [rightBarButtonItems removeObject:self.editItineraryButton];
        [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:NO];
    }
}


#pragma mark - places to go table view

- (void)setAttributesOfPlaceCell:(Place *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    place.fetchIfNeeded;
    placeTableViewCell.placeName.text = place[@"name"];
    NSLog(@"Setting places to go cell for %@ and the whole place dict is %@", place[@"name"], place);
    placeTableViewCell.placeRatings.text = [NSString stringWithFormat:@"%@ out of 5 stars", place[@"rating"]];
    placeTableViewCell.placeAddress.text = place[@"address"];
    NSLog(@"The formatted addres is %@", place[@"address"]);
    placeTableViewCell.placeFavoriteCount.text = [NSString stringWithFormat:@"Favorited by %@ other users", place[@"favoriteCount"]];
    
    // get first photo to display
    NSString *firstPhotoReference = ((place[@"photos"])[0])[@"photo_reference"];
    NSLog(@"This is the first photo's reference: %@", firstPhotoReference);
    NSString *requestURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", firstPhotoReference];
    [placeTableViewCell.placeImage setImageWithURL:[NSURL URLWithString:requestURLString]];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlaceTableViewCell *placeCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    NSLog(@"In Itinerary Detail View Controller tableview should have %lu places to go", self.itinerary.placesToGo.count);
    Place *placeToGo = self.itinerary.placesToGo[indexPath.row];
    [self setAttributesOfPlaceCell:placeToGo placeTableViewCell:placeCell];
    NSLog(@"Finished setting up attributes of place cell");
    return placeCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itinerary.placesToGo.count;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Got segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"ActivityHistorySegue"]) {
        NSLog(@"Preparing for ActivityHistorySegue");
        UINavigationController *navigationController = [segue destinationViewController];
        ActivityHistoryViewController *activityHistoryViewController = (ActivityHistoryViewController *)navigationController.topViewController;
        activityHistoryViewController.itinerary = self.itinerary;
    } else if ([[segue identifier] isEqualToString:@"ShortestRouteMapSegue"]) {
        NSLog(@"Preparing for ShortestRouteMapSegue");
        self.mapLoadingIndicator.hidden = NO;
        [self.mapLoadingIndicator startAnimating];
        UINavigationController *navigationController = [segue destinationViewController];
        ShortestRouteMapViewController *shortestRouteMapViewController = (ShortestRouteMapViewController *)navigationController.topViewController;
        shortestRouteMapViewController.itinerary = self.itinerary;
        shortestRouteMapViewController.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"EditItinerarySegue"]) {
        NSLog(@"Preparing for EditItinerarySegue");
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeItineraryViewController *composeItineraryViewController = (ComposeItineraryViewController *)navigationController.topViewController;
        composeItineraryViewController.editDelegate = self;
        composeItineraryViewController.editingMode = YES;
        composeItineraryViewController.itinerary = self.itinerary;
    } else if ([[segue identifier] isEqualToString:@"ShareItinerarySegue"]) {
        NSLog(@"Preparing for ShareItinerarySegue");
        UINavigationController *navigationController = [segue destinationViewController];
        ShareItineraryViewController *shareItineraryViewController = (ShareItineraryViewController *)navigationController.topViewController;
        shareItineraryViewController.itinerary = self.itinerary;
    }
}

- (void)stopLoadingIndicator {
    NSLog(@"stopLoadingIndicator called");
    [self.mapLoadingIndicator stopAnimating];
    self.mapLoadingIndicator.hidden = YES;
}


- (void)didEditItinerary:(nonnull Itinerary *)itinerary {
    NSLog(@"In didEditItinerary with itinerary %@", itinerary);
    self.itineraryNameLabel.text = self.itinerary[@"name"];
    self.itineraryDatesLabel.text = [NSString stringWithFormat:@"%@ - %@", self.itinerary[@"startDate"], self.itinerary[@"endDate"]];
    self.transportationDetailsLabel.text = self.itinerary[@"travelDetails"];
    self.lodgingDetailsLabel.text = self.itinerary[@"lodgingDetails"];
    [self.placesToGoTableView reloadData];
}


@end
