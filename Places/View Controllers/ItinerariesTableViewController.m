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
#import "UIKit+AFNetworking.h"
#import "ItineraryDetailViewController.h"
#import "PFNavigationDropdownMenu.h"
@import Parse;

@interface ItinerariesTableViewController () <ComposeItineraryViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *itinerariesTableView;
@property (strong, nonatomic) NSMutableArray* itinerariesToDisplay; // Array of Itinerary Parse objects
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *typeOfItineraries;

@end

@implementation ItinerariesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchItineraries) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self setupNavigationDropdownMenu];
    
    self.itinerariesTableView.dataSource = self;
    self.itinerariesTableView.delegate = self;
    self.itinerariesTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.itinerariesToDisplay = [[NSMutableArray alloc] init];
    
    if (!self.typeOfItineraries) {
        self.typeOfItineraries = @"My Itineraries";
    }
    [self fetchItineraries];
}

- (void)setupNavigationDropdownMenu {
    NSArray *dropdownMenuOptions = [NSArray arrayWithObjects:@"My Itineraries", @"Shared With Me", nil];
    PFNavigationDropdownMenu *dropdownMenu = [[PFNavigationDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 300, 44) title:dropdownMenuOptions.firstObject items:dropdownMenuOptions containerView:self.view];
    dropdownMenu.didSelectItemAtIndexHandler = ^(NSUInteger indexPath) {
        NSLog(@"Did select item at index: %ld which is %@", indexPath, dropdownMenuOptions[indexPath]);
        self.typeOfItineraries = dropdownMenuOptions[indexPath];
        [self fetchItineraries];
    };
    self.navigationItem.titleView = dropdownMenu;
}

- (void)fetchItineraries {
    PFUser *user = [PFUser currentUser];
    if ([self.typeOfItineraries  isEqual: @"My Itineraries"]) {
        if (user[@"itineraries"]) {
            NSLog(@"The user's itineraries are: %@", self.itinerariesToDisplay);
        } else {
            NSLog(@"The user currently has no itineraries");
        }
        self.itinerariesToDisplay = [[[user[@"itineraries"] reverseObjectEnumerator] allObjects] mutableCopy]; // display from most to least recently created
    } else {
        NSLog(@"Going to load shared itineraries");
    
        NSPredicate *pred = [NSPredicate predicateWithFormat: @"usersWithViewAccess IN %@ OR usersWithEditAccess IN %@", @[[PFUser currentUser]], @[[PFUser currentUser]]];
        PFQuery *query = [PFQuery queryWithClassName:@"Itinerary" predicate:pred];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable sharedItineraries, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"Got sharedItineraries: %@", sharedItineraries);
                self.itinerariesToDisplay = [[[sharedItineraries reverseObjectEnumerator] allObjects] mutableCopy];
                [self.itinerariesTableView reloadData];
            } else {
                NSLog(@"Couldn't fetch shared itineraries");
            }
        }];
    }
    [self.itinerariesTableView reloadData];
    [self.refreshControl endRefreshing];
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
    itineraryCell.itineraryDates.text = [NSString stringWithFormat:@"%@ - %@", itinerary[@"startDate"], itinerary[@"endDate"]];

    itineraryCell.itineraryImage.image = [UIImage imageNamed:@"placeholder"]; // placeholder image
    itineraryCell.itineraryImage.file = itinerary[@"image"]; // remote image
    
    // this part is janky rn - completion block only executes when tap on cell / lightly nudge table view. Why is this?
    [itineraryCell.itineraryImage loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (indexPath.row == 0) {
            NSLog(@"Finished loading first itinerary's image");
            // reload the top most table view cell for when this needs to happen after just having added a new itinerary
            // could add logic here to only do the following line if a new itinerary was just added, but shouldn't be a huge cost as is because
            // only reloading the first row, and if not new itinerary, image for first row will be cached
            [self.itinerariesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    return itineraryCell;
}

- (void)didComposeItinerary:(Itinerary *)itinerary {
    NSLog(@"did compose itinerary called with %@", itinerary);
    [self.itinerariesToDisplay insertObject:itinerary atIndex:0]; // newly created itineraries show up at the top of the page
    NSLog(@"itineraries to display is now %@", self.itinerariesToDisplay);
    [self.itinerariesTableView reloadData];
}

- (void)didUpdateItinerary:(Itinerary *)itinerary {
    NSLog(@"did update itinerary called with %@", itinerary);
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
        ItineraryTableViewCell *tappedItinerary = sender;
        ItineraryDetailViewController *itineraryDetailViewController = [segue destinationViewController];
        itineraryDetailViewController.itinerary = tappedItinerary.itinerary;
    }
}

@end
