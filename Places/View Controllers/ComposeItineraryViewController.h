//
//  ComposeItineraryViewController.h
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"
#import "DiscoverViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ComposeItineraryViewControllerDelegate

- (void)didComposeItinerary:(Itinerary *)itinerary;

@end

@interface ComposeItineraryViewController : UIViewController
@property (nonatomic, weak) id<ComposeItineraryViewControllerDelegate> delegate;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic) BOOL editingMode;
@property (strong, nonatomic) Itinerary *itinerary;

@end

NS_ASSUME_NONNULL_END
