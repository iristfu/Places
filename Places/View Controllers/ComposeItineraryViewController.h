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

@protocol EditItineraryViewControllerDelegate

- (void)didEditItinerary:(Itinerary *)itinerary;

@end

@interface ComposeItineraryViewController : UIViewController
@property (nonatomic, weak) id<ComposeItineraryViewControllerDelegate> delegate;
@property (nonatomic, weak) id<EditItineraryViewControllerDelegate> editDelegate;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic) BOOL editingMode;
@property (strong, nonatomic) Itinerary *itinerary;
@property (strong, nonatomic) NSArray *autogenerateForPlaceTypes;
@property (strong, nonatomic) NSString *region;
@property (strong, nonatomic) NSNumber *numPlacesToGenerate;
@end

NS_ASSUME_NONNULL_END
