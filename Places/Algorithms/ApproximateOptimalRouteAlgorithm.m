//
//  ApproximateOptimalRouteAlgorithm.m
//  Places
//
//  Created by Iris Fu on 8/1/22.
//

#import "ApproximateOptimalRouteAlgorithm.h"
#import "Place.h"
#import "PlaceTuple.h"
#import "Route.h"

@implementation ApproximateOptimalRouteAlgorithm

- (Route *)optimalRouteForPlacesToVisit:(NSArray<Place *> *)places
                             withValues:(NSDictionary<PlaceTuple *, NSNumber *> *)values {
    NSInteger smallestValue = INT_MAX;
    Route *shortestRoute = [[NSMutableArray alloc]init];
    for (Place *startingPlace in places)  {
        NSInteger totalValue = 0;
        NSMutableSet<Place *> *unvisited = [NSMutableSet setWithArray:places];
        [unvisited removeObject:startingPlace];
        Route *route = [[NSMutableArray alloc]initWithObjects:startingPlace, nil];
        Place *placeFrom = startingPlace;
        
        while ([unvisited count] != 0) {
            NSArray *closestPlaceInfo = [self getClosestFrom:placeFrom toPlaces:unvisited withValues:values];
            Place *nextPlace = closestPlaceInfo[0];
            [route addObject:nextPlace];
            [unvisited removeObject:nextPlace];
            placeFrom = nextPlace;
            NSInteger closestPlaceValue = [closestPlaceInfo[1] integerValue];
            totalValue += closestPlaceValue;
            
        }
        if (totalValue < smallestValue) {
            smallestValue = totalValue;
            shortestRoute = route;
        }
    }
    return shortestRoute;
}


- (NSArray *)getClosestFrom:(Place *)placeFrom toPlaces:(NSSet<Place *> *)unvisited
                 withValues:(NSDictionary<PlaceTuple *, NSNumber *> *)values {
    NSInteger smallestValue = INT_MAX;
    Place *closestPlace;
    
    for (Place *potentialPlace in unvisited) {
//        NSSet *pair = [NSSet setWithObjects:placeFrom, potentialPlace, nil];
        PlaceTuple *placeTuple = [[PlaceTuple alloc] initWithOrigin:placeFrom andDestination:potentialPlace];
        NSInteger value = [values[placeTuple] integerValue];
        if (value < smallestValue) {
            smallestValue = value;
            closestPlace = potentialPlace;
        }
    }
    NSArray *closestInfo = [NSArray arrayWithObjects:closestPlace,[NSNumber numberWithInteger: smallestValue],nil];
//    NSLog(@"closest place info %@", closestInfo);
    return closestInfo;
}

@end
