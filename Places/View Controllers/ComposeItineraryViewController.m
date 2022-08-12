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

@property (strong, nonatomic) NSMutableArray *allPlaces;
@property (strong, nonatomic) NSMutableArray *trimmedPlacesToGo;

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
    
    if (self.autogenerateForPlaceTypes) {
        NSLog(@"There are autogenerateForPlaceTypes %@", self.autogenerateForPlaceTypes);
        [self fetchAllPlacesIn:self.region withTypes:self.autogenerateForPlaceTypes callback:^(NSError *error, BOOL success) {
            if (success) {
                NSLog(@"self.allPlaceIDs after fetch method %@", self.allPlaces);
                [self trimPlacesEvenlyAcrossTypesTo:[self.numPlacesToGenerate intValue] callback:^(NSError *error, BOOL success) {
                    if (success) {
                        NSLog(@"trimmed successfully and table view should be reloaded");
                    }
                }];
            }
        }];
    }
    NSLog(@"The %lu places to go for this existing itinerary are %@",  (unsigned long)self.itinerary.placesToGo.count, self.itinerary.placesToGo);
    [self.placesToGoTableView reloadData];
}

- (void)trimPlacesEvenlyAcrossTypesTo:(int)numPlaces callback:(void (^)(NSError *error, BOOL success))callback {
    self.trimmedPlacesToGo = [[NSMutableArray alloc]init];
    NSLog(@"self.allPlaces.count %lu", (unsigned long)self.allPlaces.count);
    NSLog(@"numPlaces %lu", (unsigned long)numPlaces);
    unsigned long selectionIndex = self.allPlaces.count / numPlaces;
    NSLog(@"selectionIndex %lu", selectionIndex);
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < self.allPlaces.count; i += selectionIndex) {
        dispatch_group_enter(group);
        NSDictionary *googlePlaceObject = self.allPlaces[i];

        PFQuery *query = [PFQuery queryWithClassName:@"Place"];
        [query whereKey:@"placeID" equalTo:googlePlaceObject[@"place_id"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *places, NSError *error) {
            if (error) {
                NSLog(@"Got an error while fetching places");
            } else {
                if ([places count] == 0) {
                    Place *newPlace = [Place new];
                    newPlace.placeID = googlePlaceObject[@"place_id"];
                    newPlace.name = googlePlaceObject[@"name"];
                    newPlace.address = googlePlaceObject[@"formatted_address"];
                    newPlace.photos = googlePlaceObject[@"photos"];
                    newPlace.rating = googlePlaceObject[@"rating"];
                    newPlace.categories = googlePlaceObject[@"types"];
                    newPlace.lat = googlePlaceObject[@"geometry"][@"location"][@"lat"];
                    newPlace.lng = googlePlaceObject[@"geometry"][@"location"][@"lng"];
                    newPlace.favoriteCount = [NSNumber numberWithInt:0];
                    [newPlace save];
                    NSLog(@"Created new Place model for %@", googlePlaceObject[@"name"]);
                    [self.trimmedPlacesToGo addObject:newPlace];
                } else {
                    // place already a Parse object
                    [self.trimmedPlacesToGo addObject:places[0]];
                }
                dispatch_group_leave(group);
            }
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"all groups completed in trimPlacesEvenlyAcrossTypesTo!");
        if (self.trimmedPlacesToGo.count > [self.numPlacesToGenerate intValue]) {
            self.trimmedPlacesToGo = [[self.trimmedPlacesToGo subarrayWithRange:NSMakeRange(0, [self.numPlacesToGenerate intValue])] mutableCopy];
        }
        NSLog(@"trimmedPlacesToGo %@", self.trimmedPlacesToGo);
        self.itinerary.placesToGo = self.trimmedPlacesToGo;
        [self.placesToGoTableView reloadData];
        callback(nil, YES);
    });
}

- (void)fetchAllPlacesIn:(NSString *)query withTypes:(NSArray *)placeTypes callback:(void (^)(NSError *error, BOOL success))callback {
    self.allPlaces = [[NSMutableArray alloc]init];
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    NSString *formattedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    NSLog(@"formattedQuery: %@", formattedQuery);
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString *type in placeTypes) {
        dispatch_group_enter(group);
        NSString *formattedType = [type stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&type=%@&key=AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE", formattedQuery, formattedType]];
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
                   if (dataDictionary[@"results"]) {
                       NSArray *resultsAsGooglePlaceObjects = dataDictionary[@"results"];
                       NSMutableArray *searchResultPlaces = [[NSMutableArray alloc] init];
                       
                       for (NSDictionary *googlePlaceObject in resultsAsGooglePlaceObjects) {
                           [searchResultPlaces addObject:googlePlaceObject];
                       }
                       [self.allPlaces addObjectsFromArray:[searchResultPlaces copy]];
                       NSLog(@"just added to allPlaces %@", self.allPlaces);
                       dispatch_group_leave(group);
                   }
                   else {
                       NSLog(@"Did not get valid json");
                   }
               }
           }];
        [task resume];
    }
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        callback(nil, YES);
    });
    
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
    if (self.itinerary.placesToGo.count > 0) {
        NSLog(@"There are %lu placesToGo for this itinerary filled out", (unsigned long)self.itinerary.placesToGo.count);
        [self setItineraryImageToBeFirstImageOfFirstPlaceToGo];
    }
    
    // set places to go
    [self.itinerary setObject:self.itinerary.placesToGo forKey:@"placesToGo"];
    
    // set activity history
    Activity *creationActivity = [Activity new];
    creationActivity.activityType = @"Edited";
    creationActivity.user = [PFUser currentUser];;
    creationActivity.timestamp = [NSDate date];
    [creationActivity save];
    self.itinerary.activityHistory = [self.itinerary.activityHistory arrayByAddingObject:creationActivity];
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
    
    if (self.editingMode && !self.autogenerateForPlaceTypes) { // this is an existing itinerary
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
    
    if (self.autogenerateForPlaceTypes) {
        NSLog(@"About to call didSaveAutogeneratedItinerary");
        [self.saveAutogeneratedDelegate didSaveAutogeneratedItinerary];
    }
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
    placeTableViewCell.placeImage.layer.cornerRadius = placeTableViewCell.placeImage.frame.size.height / 16;
    placeTableViewCell.placeImage.layer.masksToBounds = YES;
    placeTableViewCell.placeImage.layer.borderWidth = 0;
    placeTableViewCell.placeImage.contentMode = UIViewContentModeScaleAspectFill;
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
