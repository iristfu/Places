//
//  ItinerariesTableViewController.m
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import "ItinerariesTableViewController.h"
#import "ItineraryTableViewCell.h"
#import "Itinerary.h"
#import "ComposeItineraryViewController.h"
#import "ParseUI.h"
#import "UIKit+AFNetworking.h"
#import "ItineraryDetailViewController.h"

@interface ItinerariesTableViewController () <ComposeItineraryViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *itinerariesTableView;
@property (strong, nonatomic) NSMutableArray* itinerariesToDisplay; // Array of Itinerary Parse objects

@end

@implementation ItinerariesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.itinerariesTableView.dataSource = self;
    self.itinerariesTableView.delegate = self;
    self.itinerariesTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.itinerariesToDisplay = [[NSMutableArray alloc] init];
    
    [self fetchItineraries];
}

- (void)fetchItineraries {
    PFUser *user = [PFUser currentUser];
    if (user[@"itineraries"]) {
        self.itinerariesToDisplay = [[[user[@"itineraries"] reverseObjectEnumerator] allObjects] mutableCopy]; // display from most to least recently created
        NSLog(@"The user's itineraries are: %@", self.itinerariesToDisplay);
        [self.itinerariesTableView reloadData];
    } else {
        NSLog(@"The user currently has no itineraries");
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itinerariesToDisplay.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"This is the index path row %ld and section %ld", (long)indexPath.row, (long)indexPath.section);
    Itinerary *itinerary = self.itinerariesToDisplay[indexPath.row];
    itinerary.fetchIfNeeded;
    
    NSLog(@"The itinerary to display for this cell is %@", itinerary);
    ItineraryTableViewCell *itineraryCell = [tableView dequeueReusableCellWithIdentifier:@"ItineraryCell" forIndexPath:indexPath];
    
    itineraryCell.itinerary = itinerary;
    itineraryCell.itineraryName.text = itinerary[@"name"];
    itineraryCell.itineraryDates.text = [NSString stringWithFormat:@"%@ - %@", itinerary[@"startDate"], itinerary[@"endDate"]]; // make this look

    itineraryCell.itineraryImage.image = [UIImage imageNamed:@"placeholder"]; // placeholder image
    itineraryCell.itineraryImage.file = itinerary[@"image"]; // remote image
    
    // this part is janky rn - completion block only executes when tap on cell / lightly nudge table view. Why is this?
    [itineraryCell.itineraryImage loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
        NSLog(@"Finished loading the image");
        // reload the top most table view cell for when this needs to happen after just having added a new itinerary
        // could add logic here to only do the following line if a new itinerary was just added, but shouldn't be a huge cost as is because
        // only reloading the first row, and if not new itinerary, image for first row will be cached
        [self.itinerariesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    return itineraryCell;
}

- (void)didComposeItinerary:(Itinerary *)itinerary {
    NSLog(@"did compose itinerary called with %@", itinerary);
    [self.itinerariesToDisplay insertObject:itinerary atIndex:0]; // newly created itineraries show up at the top of the page
//    [self.itinerariesTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    NSLog(@"itineraries to display is now %@", self.itinerariesToDisplay);
    [self.itinerariesTableView reloadData];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ComposeItinerarySegue"]) {
        NSLog(@"Preparing for ComposeItinerarySegue");
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeItineraryViewController *composeItineraryViewController = (ComposeItineraryViewController *)navigationController.topViewController;
        composeItineraryViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ItineraryDetailViewSegue"]) {
        ItineraryDetailViewController *itineraryDetailViewController = [segue destinationViewController];
        // Pass the selected object to the new view controller.
        ItineraryTableViewCell *tappedItinerary = sender;
        // TODO: set itinerary for itineraryDetailViewController
//        detailsViewController.post = tappedPost.post;
    }
}

@end
