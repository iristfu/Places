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
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
