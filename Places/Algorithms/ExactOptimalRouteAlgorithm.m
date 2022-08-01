//
//  ExactOptimalRouteAlgorithm.m
//  Places
//
//  Created by Iris Fu on 8/1/22.
//

#import "ExactOptimalRouteAlgorithm.h"
#import "Place.h"
#import "PlaceTuple.h"
#import "Route.h"

@implementation ExactOptimalRouteAlgorithm

- (Route *)optimalRouteForPlacesToVisit:(NSArray<Place *> *)places
                          withValues:(NSDictionary<PlaceTuple *, NSNumber *> *)values {
    @autoreleasepool {
        NSArray<NSArray*> *allPossibleRoutes = [self getPermutations:places];
        NSLog(@"This is all possible routes %@", allPossibleRoutes);
        float shortestRouteValue = MAXFLOAT;
        NSLog(@"shortestRouteValue initiated to %f", shortestRouteValue);
        NSArray *shortestRoute = [NSArray array];
        for (Route *route in allPossibleRoutes) {
            NSLog(@"This is one possible route %@", route);
            float value = [self getValue:route withValues:values];
            NSLog(@"The value is %f", value);
            if (value < shortestRouteValue) {
                shortestRouteValue = value;
                NSLog(@"New shortestRouteValue is %f", shortestRouteValue);
                shortestRoute = route;
            }
        }
//        self.durationsBetweenPlaces = nil;
//        self.distancesBetweenPlaces = nil;
        NSLog(@"The shortest route is %@", shortestRoute);
        // might need to release allPossibleRoutes somewhere here
        return [shortestRoute mutableCopy]; 
    }
}

- (NSArray<Route *> *)getPermutations:(NSArray*)placesToGo {
    @autoreleasepool {
        NSMutableArray *permutations = [[NSMutableArray alloc]init];
        if (placesToGo.count == 1) {
            [permutations addObject:placesToGo];
            return [permutations copy];
        }
        @autoreleasepool {
            for (int i = 0; i < placesToGo.count; i++) {
                Place *origin = placesToGo[i];
                NSArray<Place *> *otherDestinations = [[placesToGo subarrayWithRange:NSMakeRange(0, i)] arrayByAddingObjectsFromArray:[placesToGo subarrayWithRange:NSMakeRange(i+1, placesToGo.count-i-1)]];
                for (NSArray *otherDestinationsPermutation in [self getPermutations:otherDestinations]) {
                    @autoreleasepool {
                        NSArray *originArray = [NSArray arrayWithObject:origin];
                        NSArray *newPermutation = [originArray arrayByAddingObjectsFromArray:otherDestinationsPermutation];
                        [permutations addObject:newPermutation];
                    }
                }
            }
            return [permutations copy];
        }
    }
}

- (float)getValue:(NSArray *)route withValues:(NSDictionary<PlaceTuple *, NSNumber *> *)values {
    float totalValue = 0;
    for (int i = 0; i < route.count - 1; i++) {
//        NSSet *pair = [NSSet setWithObjects:route[i], route[i+1], nil];
        PlaceTuple *placeTuple = [[PlaceTuple alloc] initWithOrigin:route[i] andDestination:route[i+1]];
        NSLog(@"One pair %@", placeTuple);
        NSNumber *value = values[placeTuple];
        NSLog(@"This pair's value is %@", value);
        totalValue += [value floatValue];
        NSLog(@"Just updated totalValue to %f", totalValue);
    }
    return totalValue;
}

@end
