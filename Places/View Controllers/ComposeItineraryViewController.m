//
//  ComposeItineraryViewController.m
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import "ComposeItineraryViewController.h"
#import "ParseUI.h"

@interface ComposeItineraryViewController ()
@property (weak, nonatomic) IBOutlet UITextField *itineraryName;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *travelDetails;
@property (weak, nonatomic) IBOutlet UITextView *lodgingDetails;
// add places to go
- (IBAction)didTapClose:(id)sender;
- (IBAction)didTapDone:(id)sender;

@end

@implementation ComposeItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"loaded compose view controller");
    
//    Itinerary *newItinerary = [Itinerary new];
//    newItinerary.name = @"test itinerary";
//    [newItinerary saveInBackground];
//    [self.delegate didComposeItinerary:newItinerary];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.travelDetails.layer.borderWidth = 1.0f;
    self.travelDetails.layer.borderColor = [[UIColor grayColor] CGColor];
    self.lodgingDetails.layer.borderWidth = 1.0f;
    self.lodgingDetails.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)didTapAnywhere:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (Itinerary *)createNewItineraryInParse {
    Itinerary *newItinerary = [Itinerary new];
    newItinerary.name = self.itineraryName.text;
    newItinerary.travelDetails = self.travelDetails.text;
    newItinerary.lodgingDetails = self.lodgingDetails.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    newItinerary.startDate = [dateFormatter stringFromDate:[self.startDatePicker date]]; // Jan 2, 2001
    newItinerary.endDate = [dateFormatter stringFromDate:[self.endDatePicker date]];
    
    // check if there are places to go
    // if not:
    NSLog(@"The image to set is %@", [UIImage imageNamed:@"placeholder_itinerary_image"]);
    newItinerary.image = [self getPFFileFromImage:[UIImage imageNamed:@"placeholder_itinerary_image"]];
    NSLog(@"Just set new itinerary's image to %@", newItinerary.image);
    
    [newItinerary saveInBackground];
    NSLog(@"Created new Itinerary for %@", self.itineraryName.text);
    return newItinerary;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTapDone:(id)sender {
    // Create new Itinerary Parse object
    Itinerary * newItinerary = [self createNewItineraryInParse];
    
    // Add Itinerary to User[@"itineraries"]
    [self addItineraryForCurrentUser:newItinerary];
    
    [self.delegate didComposeItinerary:newItinerary];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
