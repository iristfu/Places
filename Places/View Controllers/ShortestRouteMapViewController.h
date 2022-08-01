//
//  ShortestRouteMapViewController.h
//  Places
//
//  Created by Iris Fu on 7/25/22.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MapShortestRouteDelegate

- (void)stopLoadingIndicator;

@end


@interface ShortestRouteMapViewController : UIViewController
@property (nonatomic, weak) id<MapShortestRouteDelegate> delegate;
@property (strong, nonatomic, nullable) Itinerary *itinerary;

@end

NS_ASSUME_NONNULL_END
