//
//  OptimalRouteAlgorithm.h
//  Places
//
//  Created by Iris Fu on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "Place.h"
#import "Route.h"

@class PlaceTuple;

@protocol OptimalRouteAlgorithm

- (Route *)optimalRouteForPlacesToVisit:(NSArray<Place *> *)places
                             withValues:(NSDictionary<PlaceTuple *, NSNumber *> *)values;

@end

