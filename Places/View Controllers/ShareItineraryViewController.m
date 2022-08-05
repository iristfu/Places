//
//  ShareItineraryViewController.m
//  Places
//
//  Created by Iris Fu on 8/3/22.
//

#import "ShareItineraryViewController.h"
#import "ShareWithUsernameCell.h"

@interface ShareItineraryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
- (IBAction)didTapShareViewOnlyLink:(id)sender;
- (IBAction)didTapShareEditLink:(id)sender;
- (IBAction)didTapDone:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *accessPermissionsButton;
@property (strong, nonatomic) IBOutlet UIMenu *accessPermissionsMenu;
@property (strong, nonatomic) NSString *accessPermission;
@property (strong, nonatomic) NSArray<PFUser *> *existingUsers;
@property (strong, nonatomic) NSArray *searchResult;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;


@end

@implementation ShareItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureAccessPermissionsButton];
    self.accessPermission = @"edit";
    
    self.usersTableView.dataSource = self;
    self.usersTableView.delegate = self;
    self.usersTableView.rowHeight = UITableViewAutomaticDimension;
    [self populateExistingUsers];
    self.searchResult =[[NSArray alloc]init];
    
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


#pragma mark - table View methods

- (void)populateExistingUsers {
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable allUsers, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"all users are %@", allUsers);
            NSMutableArray *allUsernames = [[NSMutableArray alloc] init];
            for (PFUser *user in allUsers) {
                [allUsernames addObject:user];
            }
            self.existingUsers = [allUsernames copy];
            NSLog(@"all usernames are %@", self.existingUsers);
            [self.usersTableView reloadData];
        } else {
            NSLog(@"Couldn't get all users");
        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.existingUsers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShareWithUsernameCell *usernameCell = [tableView dequeueReusableCellWithIdentifier:@"ShareWithUsernameCell" forIndexPath:indexPath];
    usernameCell.usernameLabel.text = self.existingUsers[indexPath.row].username;
    usernameCell.user = self.existingUsers[indexPath.row];
    usernameCell.itinerary = self.itinerary;
    usernameCell.accessPermission = self.accessPermission;
    return usernameCell;
}

#pragma mark - search methods

-(void) filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    self.searchResult = [self.existingUsers filteredArrayUsingPredicate:resultPredicate];
    [self.usersTableView reloadData];
}


-(BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString  {
    [self filterContentForSearchText:searchString scope:[[self.searchBar scopeButtonTitles] objectAtIndex:[self.searchBar selectedScopeButtonIndex]]] ;
    return YES;
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

@end
