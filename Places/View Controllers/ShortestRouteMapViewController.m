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
@property (weak, nonatomic) IBOutlet UIMenu *travelModeMenu;
@property (weak, nonatomic) IBOutlet UIButton *travelModeButton;
@property (weak, nonatomic) NSString *selectedTravelMode;

@end

@implementation ShortestRouteMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up travel mode button
    UIAction *driving = [UIAction actionWithTitle:@"driving" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"driving";
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
    }];
    
    UIAction *bicycling = [UIAction actionWithTitle:@"bicycling" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"bicycling";
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
    }];
    UIAction *transit = [UIAction actionWithTitle:@"transit" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"transit";
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
    }];
    UIAction *walking = [UIAction actionWithTitle:@"walking" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"walking";
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
    }];
    
    UIMenu *menu = [UIMenu menuWithChildren:@[driving, bicycling, transit, walking]];
    self.travelModeButton.menu = menu;
    NSLog(@"this is the button's menu: %@", self.travelModeButton.menu);
    self.travelModeButton.showsMenuAsPrimaryAction = true;
    self.travelModeButton.changesSelectionAsPrimaryAction = true;
    
    
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
