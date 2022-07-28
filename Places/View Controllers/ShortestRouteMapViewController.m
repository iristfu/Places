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
@property (weak, nonatomic) IBOutlet UIButton *optimizedCriteriaButton;
@property (weak, nonatomic) IBOutlet UIMenu *optimizedCriteriaMenu;
@property (weak, nonatomic) NSString *selectedTravelMode;
@property (weak, nonatomic) NSString *selectedOptimizationCriteria;
@property (weak, nonatomic) NSString *originParameter;
@property (weak, nonatomic) NSString *destinationParameter;
@property (weak, nonatomic) NSMutableString *waypointsParameter;
@property (strong, nonatomic) GMSPolyline *currentRoute;
@property (strong, nonatomic) NSMutableArray *markers;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *routeLoadingIndicator;

@property (strong, nonatomic) NSMutableDictionary *durationsBetweenPlaces;
@property (strong, nonatomic) NSMutableDictionary *distancesBetweenPlaces;

@property (strong, nonatomic) NSArray *optimalOrderingOfPlacesToGo;

@end

@interface NSObject (SafeCast)
+ (nullable instancetype)castFrom:(id)object;
@end

@implementation NSObject (SafeCast)
+ (nullable instancetype)castFrom:(id)object {
   return [object isKindOfClass:self] ? object : nil;
}
@end

@implementation ShortestRouteMapViewController

- (void)reroute {
    [self getStartingWaypointsEndingParameters];
    self.currentRoute.map = nil; // remove previous route
    [self requestRouteToDraw];
}

- (void)configureTravelModeButton {
    UIAction *driving = [UIAction actionWithTitle:@"driving" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"driving";
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
        [self reroute];
    }];
    UIAction *bicycling = [UIAction actionWithTitle:@"bicycling" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"bicycling";
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
        [self reroute];
    }];
    UIAction *walking = [UIAction actionWithTitle:@"walking" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedTravelMode = @"walking";
        NSLog(@"Just set selectedTravelMode to %@", self.selectedTravelMode);
        [self reroute];
    }];
    UIMenu *menu = [UIMenu menuWithChildren:@[driving, bicycling, walking]];
    self.travelModeButton.menu = menu;
    self.travelModeButton.showsMenuAsPrimaryAction = true;
    self.travelModeButton.changesSelectionAsPrimaryAction = true;
}

- (void)configureOptimizedCriteriaButton {
    UIAction *duration = [UIAction actionWithTitle:@"duration" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedOptimizationCriteria = @"duration";
        NSLog(@"Just set selectedOptimizationCriteria to %@", self.selectedOptimizationCriteria);
        [self reroute];
    }];
    UIAction *distance = [UIAction actionWithTitle:@"distance" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.selectedOptimizationCriteria = @"distance";
        NSLog(@"Just set selectedOptimizationCriteria to %@", self.selectedOptimizationCriteria);
        [self reroute];
    }];
    UIMenu *menu = [UIMenu menuWithChildren:@[duration, distance]];
    self.optimizedCriteriaButton.menu = menu;
    self.optimizedCriteriaButton.showsMenuAsPrimaryAction = true;
    self.optimizedCriteriaButton.changesSelectionAsPrimaryAction = true;
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

- (void)showCannotRouteAlert {
    UIAlertController *cannotRouteAlert = [UIAlertController alertControllerWithTitle:@"Uh oh"
                                                                               message:@"Cannot create a route with less than two places!"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [cannotRouteAlert addAction:okAction];
    [self presentViewController:cannotRouteAlert animated:YES completion:^{}];
}

- (NSArray<NSSet*> *)getPairsOfPlaces {
    NSArray *placesToGo = self.itinerary.placesToGo;
    NSInteger numPlacesToGo = placesToGo.count;
    NSMutableArray *pairsOfPlaces = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numPlacesToGo; i++) {
        if (i + 1 < numPlacesToGo) {
            for (int j = i + 1; j < numPlacesToGo; j++) {
                NSSet *newPair = [NSSet setWithObjects:placesToGo[i], placesToGo[j], nil];
                [pairsOfPlaces addObject:newPair];
            }
        }
    }
    return [pairsOfPlaces copy];
}


- (void)getDurationsAndDistancesBetween:(NSArray *)pairsOfPlaces {
    for (NSSet *pair in pairsOfPlaces) {
        NSArray *pairAsArray = [pair allObjects];
        Place *origin = pairAsArray[0];
        Place *dest = pairAsArray[1];
        origin.fetchIfNeeded;
        dest.fetchIfNeeded;
        NSString *originParam = [NSString stringWithFormat:@"place_id:%@", origin.placeID];
        NSString *destParam = [NSString stringWithFormat:@"place_id:%@", dest.placeID];
        
        NSString *urlString = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/distancematrix/json?destinations=%@&origins=%@&key=%@", destParam, originParam, @"AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE"];
        NSLog(@"This is the distance matrix urlString %@", urlString);
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setCompletionBlock:^{
            NSError *error = [request error];
            NSString *response = [request responseString];
            NSLog(@"%@",response);
            NSDictionary *json =[NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:&error];
            
            NSLog(@"This is json %@", json);
            // check valid json
            if ([self includesValidDistanceAndDuration:json]) {
                NSNumber *duration = json[@"rows"][0][@"elements"][0][@"duration"][@"value"];
                NSNumber *distance = json[@"rows"][0][@"elements"][0][@"distance"][@"value"];
                NSLog(@"The duration is %@ and distance is %@", duration, distance);
                // store smaller values so when adding total value for a given route, no overflows occur
                float durationToStore = [duration floatValue] / 1000;
                float distanceToStore = [distance floatValue] / 1000;
                // Objective C seems to be able to use sets as keys in a dictionary?
                [self.durationsBetweenPlaces setObject:[NSNumber numberWithFloat: durationToStore] forKey:pair];
                [self.distancesBetweenPlaces setObject:[NSNumber numberWithFloat: distanceToStore] forKey:pair];
            } else {
                [self couldNotLoadRequestAlert];
            }
            [self.routeLoadingIndicator stopAnimating];
        }];
        [request setFailedBlock:^{
            NSLog(@"error occured, %@", [request error]);
            [self couldNotLoadRequestAlert];
            [self.routeLoadingIndicator stopAnimating];
        }];
        [request startSynchronous];
    }
    NSLog(@"Got durations between places dictionary with %lu entries: %@", (unsigned long)self.durationsBetweenPlaces.count, self.durationsBetweenPlaces);
    NSLog(@"Got distances between places dictionary with %lu entires: %@", (unsigned long)self.distancesBetweenPlaces.count, self.distancesBetweenPlaces);
}

- (NSArray<NSArray*>*)getPermutations:(NSArray*)placesToGo {
    NSMutableArray *permutations = [[NSMutableArray alloc]init];
    if (placesToGo.count == 1) {
        [permutations addObject:placesToGo];
        return permutations;
    } else {
        for (int i = 0; i < placesToGo.count; i++) {
            Place *origin = placesToGo[i];
            NSArray<Place *> *otherDestinations = [[placesToGo subarrayWithRange:NSMakeRange(0, i)] arrayByAddingObjectsFromArray:[placesToGo subarrayWithRange:NSMakeRange(i+1, placesToGo.count-i-1)]];
            for (NSArray *otherDestinationsPermutation in [self getPermutations:otherDestinations]) {
                NSArray *originArray = [NSArray arrayWithObject:origin];
                NSArray *newPermutation = [originArray arrayByAddingObjectsFromArray:otherDestinationsPermutation];
                [permutations addObject:newPermutation];
            }
        }
        return [permutations copy];
    }
}

// The value this function returns is dependent on the selected optimization criteria, duration or distance
- (float)getValue:(NSArray *)route {
    float totalValue = 0;
    for (int i = 0; i < route.count - 1; i++) {
        NSSet *pair = [NSSet setWithObjects:route[i], route[i+1], nil];
        NSLog(@"One pair %@", pair);
        NSNumber *value = [self.selectedOptimizationCriteria  isEqual: @"duration"] ? self.durationsBetweenPlaces[pair] : self.distancesBetweenPlaces[pair];
        NSLog(@"This pair's value is %@", value);
        totalValue += [value floatValue];
        NSLog(@"Just updated totalValue to %f", totalValue);
    }
    return totalValue;
}

- (NSArray *)getOptimalOrderingOfPlacesToGoUsingBruteForce {
    NSArray<NSArray*> *allPossibleRoutes = [self getPermutations:self.itinerary.placesToGo];
    NSLog(@"This is all possible routes %@", allPossibleRoutes);
    float shortestRouteValue = MAXFLOAT;
    NSLog(@"shortestRouteValue initiated to %f", shortestRouteValue);
    NSArray *shortestRoute = [NSArray array];
    for (NSArray *route in allPossibleRoutes) {
        NSLog(@"This is one possible route %@", route);
        float value = [self getValue:route];
        NSLog(@"The value is %f", value);
        if (value < shortestRouteValue) {
            shortestRouteValue = value;
            NSLog(@"New shortestRouteValue is %f", shortestRouteValue);
            shortestRoute = route;
        }
    }
    NSLog(@"The shortest route is %@", shortestRoute);
    return shortestRoute;
}

- (void)getStartingWaypointsEndingParameters {
    NSArray *pairsOfPlaces = [self getPairsOfPlaces];
    NSLog(@"Got %lu pairsOfPlaces %@", (unsigned long)pairsOfPlaces.count, pairsOfPlaces);
    
    [self getDurationsAndDistancesBetween:pairsOfPlaces];
    self.optimalOrderingOfPlacesToGo = [self getOptimalOrderingOfPlacesToGoUsingBruteForce];
    
    NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:self.optimalOrderingOfPlacesToGo.count];
    for (Place *place in self.optimalOrderingOfPlacesToGo) {
        place.fetchIfNeeded;
        [parameters addObject:[NSString stringWithFormat:@"place_id:%@", place.placeID]];
    }
    if (parameters.count >= 2) { // ensure that there will be an origin and a destination
        self.originParameter = parameters[0];
        [parameters removeObjectAtIndex:0];
        self.destinationParameter = parameters[parameters.count - 1];
        [parameters removeObjectAtIndex:(parameters.count - 1)];
    } else {
        self.originParameter = nil;
        self.destinationParameter = nil;
        [self showCannotRouteAlert];
    }
    if (parameters.count > 0) {
        self.waypointsParameter = [parameters componentsJoinedByString:@"|"];
    } else {
        self.waypointsParameter = nil;
    }
    NSLog(@"waypointsParameter: %@", self.waypointsParameter);
    NSLog(@"originParameter: %@", self.originParameter);
    NSLog(@"destinationParameter: %@", self.destinationParameter);
}

- (void)requestRouteToDraw {
    NSString *urlString;
    if (self.waypointsParameter) {
        urlString = [NSString stringWithFormat: @"%@?origin=%@&destination=%@&waypoints=%@&sensor=true&mode=%@&key=%@",
                               @"https://maps.googleapis.com/maps/api/directions/json",
                               self.originParameter,
                               self.destinationParameter,
                               self.waypointsParameter,
                               self.selectedTravelMode,
                               @"AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE"];
    } else {
        urlString = [NSString stringWithFormat: @"%@?origin=%@&destination=%@&sensor=true&mode=%@&key=%@",
                               @"https://maps.googleapis.com/maps/api/directions/json",
                               self.originParameter,
                               self.destinationParameter,
                               self.selectedTravelMode,
                               @"AIzaSyA2kTwxS9iiwWd3ydaxxwdewfAjZdKJeDE"];
    }
    NSLog(@"This is the urlString %@", urlString);
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *directionsURL = [NSURL URLWithString:urlString];
    NSLog(@"This is the request url %@", directionsURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:directionsURL];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (UIImage *)getNumberedIconFor:(NSInteger)i {
    NSString *urlString = [NSString stringWithFormat:@"https://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%ld|FF0000|000000", i + 1];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:urlString]];
    // TODO: look into caching this for a future PR
    UIImage *iconImage = [UIImage imageWithData: imageData];
    return iconImage;
}

- (void)addMarkersForAllPlacesToGo {
    for (NSInteger i=0; i < [self.optimalOrderingOfPlacesToGo count]; i++) {
        Place *place = self.optimalOrderingOfPlacesToGo[i];
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
    
    for (GMSMarker *marker in self.markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }

    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:50.0f]];
}

- (void)configureMapView {
    [self configureCameraPosition];
    [self getStartingWaypointsEndingParameters];
    [self requestRouteToDraw];
    [self addMarkersForAllPlacesToGo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.routeLoadingIndicator startAnimating];
}

// called after viewDidLoad
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"In view will Appear");
    
    self.markers = [[NSMutableArray alloc] init];
    self.distancesBetweenPlaces = [[NSMutableDictionary alloc] init];
    self.durationsBetweenPlaces = [[NSMutableDictionary alloc] init];
    self.selectedOptimizationCriteria = @"duration";
    self.selectedTravelMode = @"driving";
    [self configureOptimizedCriteriaButton];
    [self configureTravelModeButton];
    [self configureMapView];
}

- (IBAction)didTapDone:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

# pragma mark - ASIHTTPRequest

- (BOOL)includesValidPath:(NSDictionary *)json {
    if (json[@"routes"]) {
        if (json[@"routes"][0]) {
            if (json[@"routes"][0][@"overview_polyline"]) {
                if (json[@"routes"][0][@"overview_polyline"][@"points"]) {
                    if ([GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]]) { // returns nil if points cannot be decoded to GMSPath
                        return true;
                    } else {
                        NSLog(@"points is not a valid GMSPath");
                        return false;
                    }
                } else {
                    NSLog(@"No points");
                    return false;
                }
            } else {
                NSLog(@"No overview polyline");
                return false;
            }
        } else {
            NSLog(@"No json[routes][0]");
            return false;
        }
    } else {
        NSLog(@"No json[routes]");
        return false;
    }
}

- (BOOL)includesValidDistanceAndDuration:(NSDictionary *)json {
    if (json[@"rows"]) {
        if (json[@"rows"][0][@"elements"]) {
            if (json[@"rows"][0][@"elements"][0][@"distance"] && json[@"rows"][0][@"elements"][0][@"duration"]) {
                if (json[@"rows"][0][@"elements"][0][@"distance"][@"value"] && json[@"rows"][0][@"elements"][0][@"duration"][@"value"]) {
                    return true;
                } else {
                    NSLog(@"No value");
                    return false;
                }
            } else {
                NSLog(@"No distance or duration");
                return false;
            }
        } else {
            NSLog(@"No json[rows][0][elements]");
            return false;
        }
    } else {
        NSLog(@"No json[rows]");
        return false;
    }
}

- (void)couldNotLoadRequestAlert {
    NSLog(@"Could not load, showing alert");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uh oh"
                                                                   message:@"Could not fetch the route from server"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSString *response = [request responseString];
    NSLog(@"%@",response);
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"This is json %@", json);
    // check valid json
    if ([self includesValidPath:json]) {
        GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
        GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
        singleLine.strokeWidth = 7;
        singleLine.strokeColor = [UIColor greenColor];
        singleLine.map = self.mapView;
        self.currentRoute = singleLine;
        NSLog(@"Just updated currentRoute to be %@", self.currentRoute);
    } else {
        [self couldNotLoadRequestAlert];
    }
    [self.routeLoadingIndicator stopAnimating];
}
 
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@",[request error]);
    [self couldNotLoadRequestAlert];
    [self.routeLoadingIndicator stopAnimating];
}

@end
