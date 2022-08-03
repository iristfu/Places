//
//  ShareItineraryViewController.m
//  Places
//
//  Created by Iris Fu on 8/3/22.
//

#import "ShareItineraryViewController.h"

@interface ShareItineraryViewController ()

@end

@implementation ShareItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

-(void)shareItinerary {
    //create a message
    NSURL *itineraryURL = [NSURL URLWithString:[NSString stringWithFormat:@"places://itinerary/%@", self.itinerary.objectId]];
    NSString *theMessage = [NSString stringWithFormat:@"Checkout my itinerary %@ that I created in the Places app! %@", self.itinerary.name, itineraryURL];
    NSArray *items = @[theMessage];

    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];

    // and present it
    [self presentActivityController:controller];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
