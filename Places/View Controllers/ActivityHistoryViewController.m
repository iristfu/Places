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
    NSLog(@"This is the activityHistoryArray %@", activityHistoryArray);
    
    NSString *allActivityHistory = @""; 
    for (Activity *activity in activityHistoryArray) {
        activity.fetchIfNeeded;
        activity.user.fetchIfNeeded;
        NSDate *timestamp = activity.timestamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle; // want to show creation time
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *timestampString = [dateFormatter stringFromDate:timestamp];
        
        NSString *activityEmoji;
        NSString *activityType = activity.activityType;
        if ([activityType isEqualToString:@"Created"]) {
            activityEmoji = @"✅";
        } else if ([activityType isEqualToString:@"Viewed"]) {
            activityEmoji = @"👀";
        } else if ([activityType isEqualToString:@"Edited"]) {
            activityEmoji = @"✍️";
        }
            
        NSString *activityAsText = [NSString stringWithFormat:@"%@ %@ by %@ on %@\n", activityEmoji, activityType, activity.user.username, timestampString];
        allActivityHistory = [allActivityHistory stringByAppendingString:activityAsText];
    }
    self.activityHistoryText.text = allActivityHistory;
}

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
