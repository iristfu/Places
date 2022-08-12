//
//  ItineraryDetailViewController.h
//  Places
//
//  Created by Iris Fu on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryDetailViewController : UIViewController

@property (strong, nonatomic) Itinerary *itinerary;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mapLoadingIndicator;
@property (strong, nonatomic) NSString *accessPermission;

@end

NS_ASSUME_NONNULL_END
