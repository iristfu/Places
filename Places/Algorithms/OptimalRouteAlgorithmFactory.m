//
//  OptimalRouteAlgorithmFactory.m
//  Places
//
//  Created by Iris Fu on 8/1/22.
//

#import "OptimalRouteAlgorithmFactory.h"
#import "ExactOptimalRouteAlgorithm.h"
#import "ApproximateOptimalRouteAlgorithm.h"

@implementation OptimalRouteAlgorithmFactory

+ (instancetype)sharedInstance {
    static OptimalRouteAlgorithmFactory *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OptimalRouteAlgorithmFactory alloc] init];
    });
    return sharedInstance;
}

- (id<OptimalRouteAlgorithm>)optimalRouteAlgorithmForPlacesToVisit:(NSArray<Place *> *)placesToVisit {
    if ([placesToVisit count] <= 5) {
        return [[ExactOptimalRouteAlgorithm alloc] init];
    } else {
        return [[ApproximateOptimalRouteAlgorithm alloc] init];
    }
}

@end
