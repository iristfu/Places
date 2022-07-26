//
//  ShortestRouteMapViewController.m
//  Places
//
//  Created by Iris Fu on 7/25/22.
//

#import "ShortestRouteMapViewController.h"
#import "ASIHTTPRequest.h"
#import "Place.h"
@import GoogleMaps;

@interface ShortestRouteMapViewController ()
- (IBAction)didTapDone:(id)sender;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIMenu *travelModeMenu;
@property (weak, nonatomic) IBOutlet UIButton *travelModeButton;
@property (weak, nonatomic) NSString *selectedTravelMode;
@property (weak, nonatomic) NSString *originParameter;
@property (weak, nonatomic) NSString *destinationParameter;
@property (weak, nonatomic) NSMutableString *waypointsParameter;

@end

@implementation ShortestRouteMapViewController

- (void)configureTravelModeButton {
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
    self.travelModeButton.showsMenuAsPrimaryAction = true;
    self.travelModeButton.changesSelectionAsPrimaryAction = true;
}

- (void)configureCameraPosition {
    Place *firstPlaceToGo = self.itinerary.placesToGo[0];
    double lat = [firstPlaceToGo.lat doubleValue];
    double lng = [firstPlaceToGo.lng doubleValue];
    NSLog(@"lat: %f lng: %f", lat, lng);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lng
                                                                 zoom:12];
    self.mapView.camera = camera;
}

- (void)getStartingWaypointsEndingParameters {
    NSArray *placesToGo = self.itinerary.placesToGo;
    NSMutableArray *placesToGoIDs = [[NSMutableArray alloc] init];
    for (Place *place in placesToGo) {
        place.fetchIfNeeded;
        [placesToGoIDs addObject:place.placeID];
    }
    NSLog(@"This is the array of places to go IDs %@", placesToGoIDs);
    
    for (NSInteger i=0; i < [placesToGoIDs count]; i++) {
        NSString *curPlaceID = placesToGoIDs[i];
        if (i == 0) {
            self.originParameter = [NSString stringWithFormat:@"place_id:%@", curPlaceID];
        } else if (i == (placesToGo.count - 1)) {
            self.destinationParameter = [NSString stringWithFormat:@"place_id:%@", curPlaceID];
        } else { // one of the waypoints
            if (self.waypointsParameter) {
                NSString *toAppend = [NSString stringWithFormat:@"|place_id:%@", curPlaceID];
                [self.waypointsParameter appendString:toAppend];
            } else { // first waypoint, don't need pipe
                self.waypointsParameter = [NSMutableString stringWithFormat:@"place_id:%@", curPlaceID];
            }
        }
    }
    NSLog(@"waypointsParameter: %@", self.waypointsParameter);
    NSLog(@"originParameter: %@", self.originParameter);
    NSLog(@"destinationParameter: %@", self.destinationParameter);
}

- (void)requestRouteToDraw {
    NSString *urlString = [NSString stringWithFormat: @"%@?origin=%@&destination=%@&waypoints=%@&sensor=true&mode=%@&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           self.originParameter,
                           self.destinationParameter,
                           self.waypointsParameter,
                           self.selectedTravelMode,
                           @"AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE"];
    NSLog(@"This is the urlString %@", urlString);
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *directionsURL = [NSURL URLWithString:urlString];
    NSLog(@"This is the request url %@", directionsURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:directionsURL];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"%@",response);
        NSDictionary *json =[NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:&error];
        GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
        GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
        singleLine.strokeWidth = 7;
        singleLine.strokeColor = [UIColor greenColor];
        singleLine.map = self.mapView;
    }
    else {
        NSLog(@"%@",[request error]);
    }
}

- (void)configureMapView {
    [self configureCameraPosition];
    [self getStartingWaypointsEndingParameters];
    [self requestRouteToDraw];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedTravelMode = @"driving";
    [self configureTravelModeButton];
    
    [self configureMapView];
}

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
