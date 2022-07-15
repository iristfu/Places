//
//  ComposeItineraryViewController.h
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ComposeItineraryViewControllerDelegate
- (void)didComposeItinerary:(Itinerary *)itinerary;

@end

@interface ComposeItineraryViewController : UIViewController
@property (nonatomic, weak) id<ComposeItineraryViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
