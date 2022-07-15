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

@interface ItinerariesTableViewController () <UITableViewDelegate, UITableViewDataSource, ComposeItineraryViewControllerDelegate>
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
    
    [self fetchItineraries];
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
    ItineraryTableViewCell *itineraryCell = [tableView dequeueReusableCellWithIdentifier:@"ItineraryCell" forIndexPath:indexPath];
    
    itineraryCell.itinerary = itinerary;
    itineraryCell.itineraryName.text = itinerary.name;
    itineraryCell.itineraryDates.text = [NSString stringWithFormat:@"%@ - %@", itinerary.startDate, itinerary.endDate]; // make this look better
    // set image
//    itineraryCell.itineraryImage
    
    return itineraryCell;
}

- (void)didComposeItinerary:(Itinerary *)itinerary {
    [self.itinerariesToDisplay insertObject:itinerary atIndex:0]; // newly created itineraries show up at the top of the page
    [self.itinerariesTableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"ComposeItinerarySegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeItineraryViewController *composeItineraryViewController = (ComposeItineraryViewController *)navigationController.topViewController;
        composeItineraryViewController.delegate = self;
    }
}


@end
