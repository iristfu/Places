//
//  ActivityHistoryViewController.m
//  Places
//
//  Created by Iris Fu on 7/21/22.
//

#import "ActivityHistoryViewController.h"

@interface ActivityHistoryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *activityHistoryText;
- (IBAction)didTapDone:(id)sender;

@end

@implementation ActivityHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *activityHistoryArray = self.itinerary.activityHistory;
    NSString *activityHistoryText = [[activityHistoryArray valueForKey:@"description"] componentsJoinedByString:@"\n"];
    NSLog(@"activityHistoryText is: %@", activityHistoryText);
    self.activityHistoryText.text = activityHistoryText;
}

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
