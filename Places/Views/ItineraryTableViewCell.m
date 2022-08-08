//
//  ItineraryTableViewCell.m
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import "ItineraryTableViewCell.h"

@implementation ItineraryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    self.itineraryImage.layer.cornerRadius = self.itineraryImage.frame.size.height / 1.5;
//    self.itineraryImage.layer.masksToBounds = YES;
//    self.itineraryImage.layer.borderWidth = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
