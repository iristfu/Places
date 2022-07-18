//
//  PlaceTableViewCell.h
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UILabel *placeRatings;
@property (weak, nonatomic) IBOutlet UILabel *placeAddress;
@property (weak, nonatomic) IBOutlet UILabel *placeFavoriteCount;
- (IBAction)didTapAddToButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addToButton;

@property (weak, nonatomic) Place *place;


@end

NS_ASSUME_NONNULL_END
