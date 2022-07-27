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

@interface ItineraryDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *itineraryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itineraryDatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportationDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lodgingDetailsLabel;
@property (weak, nonatomic) IBOutlet UITableView *placesToGoTableView;
- (IBAction)didTapShare:(id)sender;

@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.itinerary.fetchIfNeeded;
    
    self.itineraryNameLabel.text = self.itinerary[@"name"];
    self.itineraryDatesLabel.text = [NSString stringWithFormat:@"%@ - %@", self.itinerary[@"startDate"], self.itinerary[@"endDate"]];
    self.transportationDetailsLabel.text = self.itinerary[@"travelDetails"];
    self.lodgingDetailsLabel.text = self.itinerary[@"lodgingDetails"];
    
    self.placesToGoTableView.delegate = self;
    self.placesToGoTableView.dataSource = self;
    
    // update activity history for given itinerary
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *currentDate = [NSDate date];

    NSString *newActivityString = [NSString stringWithFormat:@"👀 Viewed by %@ on %@", [PFUser currentUser].username, [dateFormatter stringFromDate:currentDate]]; // Adds logged in user's view to Itinerary's activity history
    self.itinerary.activityHistory = [self.itinerary.activityHistory arrayByAddingObject:newActivityString];
    NSLog(@"Updated itinerary activity history: %@", self.itinerary.activityHistory);
    [self.itinerary saveInBackground];
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];

    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;

    
    // set up alerts for post share
    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                               message:@"Shared successfully!"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertController *failureAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Couldn't share itinerary. Try again later."
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [successAlert addAction:okAction];
    [failureAlert addAction:okAction];
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            [self presentViewController:successAlert animated:YES completion:^{}];
        } else if (error == nil) {
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        } else {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
            [self presentViewController:failureAlert animated:YES completion:^{}];
        }
    };
}

-(void)shareItinerary {
    //create a message
    NSURL *itineraryURL = [NSURL URLWithString:[NSString stringWithFormat:@"places://itinerary/%@", self.itinerary.objectId]];
    NSString *theMessage = [NSString stringWithFormat:@"Checkout my itinerary %@ that I created in the Places app! %@", self.itinerary.name, itineraryURL];
    NSArray *items = @[theMessage];

    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];

    // and present it
    [self presentActivityController:controller];
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
    NSLog(@"In Itinerary Detail View Controller - Dequed a placeCell to set up");
    Place *placeToGo = self.itinerary.placesToGo[indexPath.row];
    [self setAttributesOfPlaceCell:placeToGo placeTableViewCell:placeCell];
    NSLog(@"Finished setting up attributes of place cell");
    return placeCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itinerary.placesToGo.count;
}

- (IBAction)didTapShare:(id)sender {
    [self shareItinerary];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ActivityHistorySegue"]) {
        NSLog(@"Preparing for ActivityHistorySegue");
        UINavigationController *navigationController = [segue destinationViewController];
        ActivityHistoryViewController *activityHistoryViewController = (ActivityHistoryViewController *)navigationController.topViewController;
        activityHistoryViewController.itinerary = self.itinerary;
    } else if ([[segue identifier] isEqualToString:@"ShortestRouteMapSegue"]) {
        NSLog(@"Preparing for ShortestRouteMapSegue");
        UINavigationController *navigationController = [segue destinationViewController];
        ShortestRouteMapViewController *shortestRouteMapViewController = (ShortestRouteMapViewController *)navigationController.topViewController;
        shortestRouteMapViewController.itinerary = self.itinerary;
    }
}

@end
