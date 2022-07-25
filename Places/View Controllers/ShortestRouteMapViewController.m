//
//  ShortestRouteMapViewController.m
//  Places
//
//  Created by Iris Fu on 7/25/22.
//

#import "ShortestRouteMapViewController.h"
@import GoogleMaps;

@interface ShortestRouteMapViewController ()
- (IBAction)didTapDone:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *mapView;

@end

@implementation ShortestRouteMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
                                                              longitude:103.848
                                                                   zoom:12];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView = mapView;
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
