//
//  SuggestItineraryViewController.h
//  Places
//
//  Created by Iris Fu on 8/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SuggestItineraryViewControllerDelegate

@end

@interface SuggestItineraryViewController : UIViewController
@property (nonatomic, weak) id<SuggestItineraryViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
