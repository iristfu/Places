//
//  PlaceTableViewCell.h
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PlaceTableViewCellDelegate

- (void)addPlaceToPlacesToGoToAdd:(Place *)place;
- (BOOL)placeIsInPlacesToGoToAdd:(Place *)place;

@end

@interface PlaceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UILabel *placeRatings;
@property (weak, nonatomic) IBOutlet UILabel *placeAddress;
@property (weak, nonatomic) IBOutlet UILabel *placeFavoriteCount;
//- (IBAction)didTapAddToButton:(id)sender;
//@property (weak, nonatomic) IBOutlet UIButton *addToButton;
- (IBAction)didTapAddToButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *addToButton;


@property (weak, nonatomic) NSString *viewFrom; // string representing which view triggered the discover view

@property (weak, nonatomic) Place *place;

@property (nonatomic, weak) id<PlaceTableViewCellDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
