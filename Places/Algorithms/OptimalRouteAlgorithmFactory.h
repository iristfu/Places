//
//  OptimalRouteAlgorithmFactory.h
//  Places
//
//  Created by Iris Fu on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@protocol OptimalRouteAlgorithm;

NS_ASSUME_NONNULL_BEGIN

@interface OptimalRouteAlgorithmFactory : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (id<OptimalRouteAlgorithm>)optimalRouteAlgorithmForPlacesToVisit:(NSArray<Place *> *)placesToVisit;

@end

NS_ASSUME_NONNULL_END
