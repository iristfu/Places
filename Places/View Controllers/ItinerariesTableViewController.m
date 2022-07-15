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
    
//    Itinerary *newItinerary = [Itinerary new];
//    newItinerary.name = @"test itinerary";
//    [newItinerary saveInBackground];
//    [self didComposeItinerary:newItinerary];
}

- (void)fetchItineraries {
    PFUser *user = [PFUser currentUser];
    if (user[@"itineraries"]) {
        self.itinerariesToDisplay = user[@"itineraries"];
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
    Itinerary *itinerary = self.itinerariesToDisplay[indexPath.row];
    itinerary.fetchIfNeeded;
    
    NSLog(@"The itinerary to display for this cell is %@", itinerary);
    ItineraryTableViewCell *itineraryCell = [tableView dequeueReusableCellWithIdentifier:@"ItineraryCell" forIndexPath:indexPath];
    
    itineraryCell.itinerary = itinerary;
    itineraryCell.itineraryName.text = itinerary[@"name"];
    itineraryCell.itineraryDates.text = [NSString stringWithFormat:@"%@ - %@", itinerary[@"startDate"], itinerary[@"endDate"]]; // make this look better
    // set image
//    itineraryCell.itineraryImage
    
    return itineraryCell;
}

- (void)didComposeItinerary:(Itinerary *)itinerary {
    NSLog(@"did compose itinerary called with %@", itinerary);
    [self.itinerariesToDisplay insertObject:itinerary atIndex:0]; // newly created itineraries show up at the top of the page
    NSLog(@"itineraries to display is now %@", self.itinerariesToDisplay);
    [self.itinerariesTableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"ComposeItinerarySegue"]) {
        NSLog(@"in compose itinerary prepare for segue");
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeItineraryViewController *composeItineraryViewController = (ComposeItineraryViewController *)navigationController.topViewController;
        composeItineraryViewController.delegate = self;
        NSLog(@"The compose view controller's delegate is %@", composeItineraryViewController.delegate);
    }
}


@end
