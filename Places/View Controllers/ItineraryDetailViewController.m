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

@interface ItineraryDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *itineraryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itineraryDatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportationDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lodgingDetailsLabel;
@property (weak, nonatomic) IBOutlet UITableView *placesToGoTableView;

@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itinerary.fetchIfNeeded;
    
    self.itineraryNameLabel.text = self.itinerary[@"name"];
    self.itineraryDatesLabel.text = [NSString stringWithFormat:@"%@ - %@", self.itinerary[@"startDate"], self.itinerary[@"endDate"]];
    
    self.transportationDetailsLabel.text = self.itinerary[@"travelDetails"];
    self.lodgingDetailsLabel.text = self.itinerary[@"lodgingDetails"];
    
//    self.itineraryNameLabel.text = self.itinerary.name;
//    self.itineraryDatesLabel.text = [NSString stringWithFormat:@"%@ - %@", self.itinerary.startDate, self.itinerary.endDate];
//
//    self.transportationDetailsLabel.text = self.itinerary.travelDetails;
//    self.lodgingDetailsLabel.text = self.itinerary.lodgingDetails;
    
    self.placesToGoTableView.delegate = self;
    self.placesToGoTableView.dataSource = self;
    
    NSLog(@"Finished viewDidLoad");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    return placeCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itinerary.placesToGo.count; // might be problematic
}

@end
