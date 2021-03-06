//
//  ItineraryTableViewCell.h
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import <UIKit/UIKit.h>
#import "Itinerary.h"
#import "ParseUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *itineraryImage;
@property (weak, nonatomic) IBOutlet UILabel *itineraryName;
@property (weak, nonatomic) IBOutlet UILabel *itineraryDates;
@property (nonatomic,strong) Itinerary *itinerary;
@end

NS_ASSUME_NONNULL_END
