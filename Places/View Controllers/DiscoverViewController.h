//
//  DiscoverViewController.h
//  Places
//
//  Created by Iris Fu on 7/10/22.
//

#import <UIKit/UIKit.h>
#import "PlaceTableViewCell.h"
#import "Itinerary.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddPlacesToGoViewDelegate

- (void) finishedAddingPlacesToGo:(NSArray *)placesToGo;
- (Itinerary *) getCurrentItinerary;

@end

@interface DiscoverViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *searchResults;
@property (weak, nonatomic) NSString *viewFrom; // string representing which view triggered the discover view
@property (nonatomic, weak) id<AddPlacesToGoViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *placesToGoToAdd;

@end

NS_ASSUME_NONNULL_END
