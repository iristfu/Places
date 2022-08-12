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
//    self.title = @"Itineraries";
    
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
        self.itinerariesToDisplay = [[[user[@"itineraries"] reverseObjectEnumerator] allObjects] mutableCopy]; // display from most to least recently created
        if (user[@"itineraries"]) {
            NSLog(@"The user's itineraries are: %@", self.itinerariesToDisplay);
        } else {
            NSLog(@"The user currently has no itineraries");
        }
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
    itineraryCell.itineraryDates.text = [NSString stringWithFormat:@"🗓 %@ - %@", itinerary[@"startDate"], itinerary[@"endDate"]];
    itineraryCell.itineraryAuthor.text = [NSString stringWithFormat:@"✍️ %@", itinerary[@"author"]];

    itineraryCell.itineraryImage.image = [UIImage imageNamed:@"placeholder"]; // placeholder image
    itineraryCell.itineraryImage.file = itinerary[@"image"]; // remote image
    itineraryCell.itineraryImage.layer.cornerRadius = itineraryCell.itineraryImage.frame.size.height / 16;
    itineraryCell.itineraryImage.layer.masksToBounds = YES;
    itineraryCell.itineraryImage.layer.borderWidth = 0;
    itineraryCell.itineraryImage.contentMode = UIViewContentModeScaleAspectFill;
    
    [itineraryCell.itineraryImage loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (indexPath.row == 0) {
            NSLog(@"Finished loading first itinerary's image");
            [self.itinerariesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    return itineraryCell;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    Itinerary *itinerary = [self.itinerariesToDisplay objectAtIndex:fromIndexPath.row];
    [self.itinerariesToDisplay removeObjectAtIndex:fromIndexPath.row];
    [self.itinerariesToDisplay insertObject:itinerary atIndex:toIndexPath.row];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
// TODO: figure out why deleting first itinerary of table view is buggy
   if (editingStyle == UITableViewCellEditingStyleDelete) {
       PFUser *currentUser = [PFUser currentUser];
       Itinerary *itineraryToDelete = [self.itinerariesToDisplay objectAtIndex:[indexPath row]];
       itineraryToDelete.fetchIfNeeded;
       NSLog(@"The itinerary to delete is %@", itineraryToDelete);

       // if current user is the author, remove itinerary for author and all users with view and editing access
       if ([itineraryToDelete.author isEqualToString:currentUser.username]) {
           [currentUser removeObject:itineraryToDelete forKey:@"itineraries"];
           [currentUser saveInBackground];
           [itineraryToDelete deleteInBackground];
       } else {
           // if current user is not author but has view/edit access, it will only be deleted for them, but not for other users
           for(PFUser *user in itineraryToDelete.usersWithEditAccess) {
               user.fetchIfNeeded;
               if ([user.username isEqualToString:currentUser.username]) {
                   [itineraryToDelete removeObject:user forKey:@"usersWithEditAccess"];
                   [itineraryToDelete saveInBackground];
               } else {
                   [itineraryToDelete removeObject:user forKey:@"usersWithViewAccess"];
                   [itineraryToDelete saveInBackground];
               }
           }
           [self showWillNotBeDeletedForOtherUsersAlert];
       }
       [self.itinerariesToDisplay removeObject:itineraryToDelete];
       [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
   }
}

- (void)showWillNotBeDeletedForOtherUsersAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This itinerary will only be deleted for you"
                                                                               message:@"Because you're not the author of this itinerary, this itinerary will only be deleted for you, and still be available for other users with access."
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
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
