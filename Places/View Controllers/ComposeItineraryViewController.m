//
//  ComposeItineraryViewController.m
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import "ComposeItineraryViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Activity.h"
@import Parse;

@interface ComposeItineraryViewController () <AddPlacesToGoViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *itineraryName;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *travelDetails;
@property (weak, nonatomic) IBOutlet UITextView *lodgingDetails;
@property (weak, nonatomic) IBOutlet UITableView *placesToGoTableView;
- (IBAction)didTapClose:(id)sender;
- (IBAction)didTapDone:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *creatingNewItineraryIndicator;
- (IBAction)didTapEdit:(id)sender;
@property (nonatomic, getter=isEditing) BOOL editing;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;


@end

@implementation ComposeItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"loaded compose view controller");
    
    self.placesToGoTableView.dataSource = self;
    self.placesToGoTableView.delegate = self;
    self.placesToGoTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.travelDetails.layer.borderWidth = 1.0f;
    self.travelDetails.layer.borderColor = [[UIColor grayColor] CGColor];
    self.lodgingDetails.layer.borderWidth = 1.0f;
    self.lodgingDetails.layer.borderColor = [[UIColor grayColor] CGColor];
    
    if (self.editingMode) {
        [self showExistingItineraryDetails];
    } else {
        self.itinerary = [Itinerary new];
    }
}

//- (void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"viewWillDisappear called");
//    [super viewWillDisappear:animated];
//    NSLog(@"The presenting view controller is %@", self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2]);
//
//    self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2].loadView;
//}

- (void)didTapAnywhere:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)setItineraryImageToBeFirstImageOfFirstPlaceToGo {
    Place *firstPlaceToGo = self.itinerary.placesToGo[0];
    NSLog(@"Setting itinerary image as the photo for %@", firstPlaceToGo[@"name"]);
    NSString *firstPhotoReference = ((firstPlaceToGo[@"photos"])[0])[@"photo_reference"];
    NSLog(@"In setItineraryImageToBeFirstImageOfFirstPlaceToGo, This is the first photo's reference: %@", firstPhotoReference);
    NSString *requestURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photo_reference=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", firstPhotoReference];
    NSLog(@"In setItineraryImageToBeFirstImageOfFirstPlaceToGo, This is the requestURLString: %@", requestURLString);
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:requestURLString]];
    NSLog(@"There is imageData %@", imageData);
    self.itinerary.image = [self getPFFileFromImage:[UIImage imageWithData:imageData]];
    NSLog(@"Just set new itinerary's image to %@", self.itinerary.image);
}

- (void)showExistingItineraryDetails {
    self.itineraryName.text = self.itinerary.name;
    self.travelDetails.text = self.itinerary.travelDetails;
    self.lodgingDetails.text = self.itinerary.lodgingDetails;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *startDate = [dateFormatter dateFromString:self.itinerary.startDate];
    NSDate *endDate = [dateFormatter dateFromString:self.itinerary.endDate];
    [self.startDatePicker setDate:startDate];
    [self.endDatePicker setDate:endDate];
    
    NSLog(@"The %lu places to go for this existing itinerary are %@",  (unsigned long)self.itinerary.placesToGo.count, self.itinerary.placesToGo);
    [self.placesToGoTableView reloadData];
    
}

- (void)createNewItineraryInParse {
    self.itinerary.name = self.itineraryName.text;
    self.itinerary.travelDetails = self.travelDetails.text;
    self.itinerary.lodgingDetails = self.lodgingDetails.text;
    
    // set dates
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    self.itinerary.startDate = [dateFormatter stringFromDate:[self.startDatePicker date]]; // Jan 2, 2001
    self.itinerary.endDate = [dateFormatter stringFromDate:[self.endDatePicker date]];
    
    // set image
    if (self.itinerary.placesToGo) {
        NSLog(@"There are placesToGo for this itinerary filled out");
        [self setItineraryImageToBeFirstImageOfFirstPlaceToGo];
    }
    
    // set author
    PFUser *currentUser = [PFUser currentUser];
    self.itinerary.author = currentUser.username;
    
    // set activity history
    Activity *creationActivity = [Activity new];
    creationActivity.activityType = @"Created";
    creationActivity.user = currentUser;
    creationActivity.timestamp = [NSDate date];
    [creationActivity save];
    self.itinerary.activityHistory = [NSArray arrayWithObject:creationActivity];
    NSLog(@"activityHistory updated with new creation activity %@", self.itinerary.activityHistory);
    
    [self.itinerary save]; // saveInBackground produces an error sometimes
    NSLog(@"Created new Itinerary for %@", self.itineraryName.text);
}

- (void)updateItineraryInParse {
    NSLog(@"updateItineraryInParse called");
    self.itinerary.name = self.itineraryName.text;
    self.itinerary.travelDetails = self.travelDetails.text;
    self.itinerary.lodgingDetails = self.lodgingDetails.text;
    
    // set dates
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    self.itinerary.startDate = [dateFormatter stringFromDate:[self.startDatePicker date]]; // Jan 2, 2001
    self.itinerary.endDate = [dateFormatter stringFromDate:[self.endDatePicker date]];
    
    // set image
    if (self.itinerary.placesToGo) {
        NSLog(@"There are placesToGo for this itinerary filled out");
        [self setItineraryImageToBeFirstImageOfFirstPlaceToGo];
    }
    
    // set places to go
    [self.itinerary setObject:self.itinerary.placesToGo forKey:@"placesToGo"];
    [self.itinerary save];
    
    // set activity history
    Activity *creationActivity = [Activity new];
    creationActivity.activityType = @"Edited";
    creationActivity.user = [PFUser currentUser];;
    creationActivity.timestamp = [NSDate date];
    [creationActivity save];
    self.itinerary.activityHistory = [NSArray arrayWithObject:creationActivity];
    NSLog(@"activityHistory updated with new creation activity %@", self.itinerary.activityHistory);
    
    [self.itinerary save]; // saveInBackground produces an error sometimes
    NSLog(@"Updated Itinerary for %@ and it now has %lu places to go", self.itineraryName.text, self.itinerary.placesToGo.count);
}

- (void)addItineraryForCurrentUser:(Itinerary *)newItinerary {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addObject:newItinerary forKey:@"itineraries"];
    [currentUser saveInBackground];
    NSLog(@"The user's itineraries array is now: %@", currentUser[@"itineraries"]);
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
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


- (IBAction)didTapDone:(id)sender {
    self.creatingNewItineraryIndicator.hidden = NO;
    [self.creatingNewItineraryIndicator startAnimating];
    
    if (self.editingMode) {
        [self updateItineraryInParse];
        NSLog(@"About to call didEditItinerary on %@", self.itinerary);
        [self.editDelegate didEditItinerary:self.itinerary];
    } else {
        // Create new Itinerary Parse object
        [self createNewItineraryInParse];

        // Add Itinerary to User[@"itineraries"]
        [self addItineraryForCurrentUser:self.itinerary];
        [self.delegate didComposeItinerary:self.itinerary];
    }
    [self.creatingNewItineraryIndicator stopAnimating];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = [segue destinationViewController];
    DiscoverViewController *discoverViewController = (DiscoverViewController *)navigationController.topViewController;
    discoverViewController.delegate = self;
    discoverViewController.viewFrom = @"ComposeView";
}


#pragma mark - AddPlacesToGoViewDelegate
- (void)finishedAddingPlacesToGo:(nonnull NSArray *)placesToGo {
    NSLog(@"finishedAddingPlacesToGo method executing");
    if (self.itinerary.placesToGo) {
        [self.itinerary.placesToGo addObjectsFromArray:placesToGo];
    } else {
        self.itinerary.placesToGo = [placesToGo mutableCopy];
    }
    if (self.editingMode) {
        [self.itinerary setObject:self.itinerary.placesToGo forKey:@"placesToGo"];
        [self.itinerary save];
        NSLog(@"Just saved itinerary after getting new places to go and it now has %lu places to go", (unsigned long)self.itinerary.placesToGo.count);
    }
    [self.placesToGoTableView reloadData];
}

- (Itinerary *)getCurrentItinerary {
    return self.itinerary;
}

#pragma mark - places to go table view

- (void)setAttributesOfPlaceCell:(Place *)place placeTableViewCell:(PlaceTableViewCell *)placeTableViewCell {
    NSLog(@"Setting attributes for %@", place);
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
    NSLog(@"For placesToGoTableView of %@ with %lu places to go, dequed a placeCell to set up", self.itinerary.name, self.itinerary.placesToGo.count);
    Place *placeToGo = self.itinerary.placesToGo[indexPath.row];
    [self setAttributesOfPlaceCell:placeToGo placeTableViewCell:placeCell];

    return placeCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"places to go count is %lu", (unsigned long)self.itinerary.placesToGo.count);
    return self.itinerary.placesToGo.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      [self.itinerary.placesToGo removeObjectAtIndex:[indexPath row]];
      [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
   }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (IBAction)didTapEdit:(id)sender {
    UITableView *tableView = [self placesToGoTableView];
    [tableView setEditing:![tableView isEditing] animated:YES];
    [sender setTitle:([tableView isEditing]) ? @"Done" : @"Edit" forState:UIControlStateNormal];
}

@end
