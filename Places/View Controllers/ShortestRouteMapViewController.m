//
//  ShortestRouteMapViewController.m
//  Places
//
//  Created by Iris Fu on 7/25/22.
//

#import "ShortestRouteMapViewController.h"
#import "ASIHTTPRequest.h"
#import "Place.h"
#import "UIImageView+AFNetworking.h"
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
@property (strong, nonatomic) GMSPolyline *currentRoute;
@property (strong, nonatomic) NSMutableArray *markers;

@end

@implementation ShortestRouteMapViewController

- (void)configureTravelModeButton {
    UIAction *driving = [UIAction actionWithTitle:@"driving" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"driving";
        [self getStartingWaypointsEndingParameters];
        self.currentRoute.map = nil; // remove previous route
        [self requestRouteToDraw];
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
    }];
    UIAction *bicycling = [UIAction actionWithTitle:@"bicycling" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"bicycling";
        [self getStartingWaypointsEndingParameters];
        self.currentRoute.map = nil; // remove previous route
        [self requestRouteToDraw];
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
    }];
    UIAction *walking = [UIAction actionWithTitle:@"walking" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"walking";
        [self getStartingWaypointsEndingParameters];
        self.currentRoute.map = nil; // remove previous route
        [self requestRouteToDraw];
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
    }];
    UIMenu *menu = [UIMenu menuWithChildren:@[driving, bicycling, walking]];
    self.travelModeButton.menu = menu;
    self.travelModeButton.showsMenuAsPrimaryAction = true;
    self.travelModeButton.changesSelectionAsPrimaryAction = true;
}

- (void)configureCameraPosition {
    Place *firstPlaceToGo = self.itinerary.placesToGo[0];
    firstPlaceToGo.fetchIfNeeded;
    NSLog(@"This is the first place to go %@", firstPlaceToGo);
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
        self.currentRoute = singleLine;
        NSLog(@"Just updated currentRoute to be %@", self.currentRoute);
    }
    else {
        NSLog(@"%@",[request error]);
    }
}

- (UIImage *)getNumberedIconFor:(NSInteger)i {
    NSString *urlString = [NSString stringWithFormat:@"https://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%ld|FF0000|000000", i + 1];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:urlString]];
    UIImage *iconImage = [UIImage imageWithData: imageData];
    return iconImage;
}

- (void)addMarkersForAllPlacesToGo {
    NSArray *placesToGo = self.itinerary.placesToGo;
    // in the future, use an ordered version of placesToGo that portrays the shortest route
    for (NSInteger i=0; i < [placesToGo count]; i++) {
        Place *place = placesToGo[i];
        place.fetchIfNeeded;
        double lat = [place.lat doubleValue];
        double lng = [place.lng doubleValue];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lat, lng);
        marker.title = place.name;
        marker.icon = [self getNumberedIconFor:i];
        marker.map = self.mapView;
        [self.markers addObject:marker];
        NSLog(@"self.markers is now %@", self.markers);
    }
    [self focusMapToShowAllMarkers];
}

- (void)focusMapToShowAllMarkers {
    CLLocationCoordinate2D firstMarker = ((GMSMarker *)self.markers.firstObject).position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstMarker coordinate:firstMarker];
    
    for (GMSMarker *marker in self.markers)
        bounds = [bounds includingCoordinate:marker.position];

    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:50.0f]];
}

- (void)configureMapView {
    [self configureCameraPosition];
    [self addMarkersForAllPlacesToGo];
    [self getStartingWaypointsEndingParameters];
    [self requestRouteToDraw];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.markers = [[NSMutableArray alloc] init];
    self.selectedTravelMode = @"driving";
    [self configureTravelModeButton];
    
    [self configureMapView];
}

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
