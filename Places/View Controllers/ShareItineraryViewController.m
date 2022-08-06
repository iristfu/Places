//
//  ShareItineraryViewController.m
//  Places
//
//  Created by Iris Fu on 8/3/22.
//

#import "ShareItineraryViewController.h"
#import "ShareWithUsernameCell.h"

@interface ShareItineraryViewController () <ShareWithUsernameCellDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
- (IBAction)didTapShareViewOnlyLink:(id)sender;
- (IBAction)didTapShareEditLink:(id)sender;
- (IBAction)didTapDone:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *accessPermissionsButton;
@property (strong, nonatomic) IBOutlet UIMenu *accessPermissionsMenu;
@property (strong, nonatomic) NSString *accessPermission;
@property (strong, nonatomic) NSMutableArray<PFUser *> *usersToDisplay;
@property (strong, nonatomic) NSArray<PFUser *> *allUsers;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;


@end

@implementation ShareItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureAccessPermissionsButton];
    self.accessPermission = @"edit";
    
    self.searchBar.delegate = self;
    self.usersTableView.dataSource = self;
    self.usersTableView.delegate = self;
    self.usersTableView.rowHeight = UITableViewAutomaticDimension;
    [self populateUsersToDisplay];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)configureAccessPermissionsButton {
    UIAction *Editor = [UIAction actionWithTitle:@"Editor" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.accessPermission = @"edit";
        NSLog(@"Just set accessPermission to %@", self.accessPermission);
        [self.usersTableView reloadData]; // update cell's accessPermission
    }];
    UIAction *Viewer = [UIAction actionWithTitle:@"Viewer" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.accessPermission = @"view";
        NSLog(@"Just set accessPermission to %@", self.accessPermission);
        [self.usersTableView reloadData]; // update cell's accessPermission
    }];
    UIMenu *menu = [UIMenu menuWithChildren:@[Editor, Viewer]];
    self.accessPermissionsButton.menu = menu;
    self.accessPermissionsButton.showsMenuAsPrimaryAction = true;
    self.accessPermissionsButton.changesSelectionAsPrimaryAction = true;
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

-(void)shareItineraryWithEditLink {
    //create a message
    NSURL *itineraryURL = [NSURL URLWithString:[NSString stringWithFormat:@"places://itinerary/%@?access=edit", self.itinerary.objectId]];
    NSString *theMessage = [NSString stringWithFormat:@"View and edit my itinerary %@ that I created in the Places app! %@", self.itinerary.name, itineraryURL];
    NSArray *items = @[theMessage];

    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];

    // and present it
    [self presentActivityController:controller];
}

-(void)shareItineraryWithViewOnlyLink {
    //create a message
    NSURL *itineraryURL = [NSURL URLWithString:[NSString stringWithFormat:@"places://itinerary/%@?access=view", self.itinerary.objectId]];
    NSString *theMessage = [NSString stringWithFormat:@"View my itinerary %@ that I created in the Places app! %@", self.itinerary.name, itineraryURL];
    NSArray *items = @[theMessage];

    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];

    // and present it
    [self presentActivityController:controller];
}

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapShareEditLink:(id)sender {
    [self shareItineraryWithEditLink];
}

- (IBAction)didTapShareViewOnlyLink:(id)sender {
    [self shareItineraryWithViewOnlyLink];
}

- (void)didTapAnywhere:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)showAlert:(nonnull UIAlertController *)alert {
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - table View methods

- (void)populateUsersToDisplay {
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *allUsers = [[NSMutableArray alloc] init];
            for (PFUser *user in users) {
                [allUsers addObject:user];
            }
            self.usersToDisplay = allUsers;
            self.allUsers = [allUsers copy];
            NSLog(@"usersToDisplay initially set to %@", self.usersToDisplay);
            [self.usersTableView reloadData];
        } else {
            NSLog(@"Couldn't get all users");
        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.usersToDisplay.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShareWithUsernameCell *usernameCell = [tableView dequeueReusableCellWithIdentifier:@"ShareWithUsernameCell" forIndexPath:indexPath];
    usernameCell.usernameLabel.text = self.usersToDisplay[indexPath.row].username;
    usernameCell.user = self.usersToDisplay[indexPath.row];
    usernameCell.itinerary = self.itinerary;
    usernameCell.accessPermission = self.accessPermission;
    usernameCell.delegate = self;
    return usernameCell;
}

#pragma mark - search methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"searchBar textDidChange called");
    if (searchText.length == 0) {
        self.usersToDisplay = [self.allUsers mutableCopy];
        [self.searchBar endEditing:YES];
    } else {
        self.usersToDisplay = [[NSMutableArray alloc]init];
        for (PFUser *user in self.allUsers) {
            NSRange range = [user.username rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [self.usersToDisplay addObject:user];
            }
        }
    }
    NSLog(@"Just updated usersToDisplay to %@", self.usersToDisplay);
    [self.usersTableView reloadData];
}

@end
