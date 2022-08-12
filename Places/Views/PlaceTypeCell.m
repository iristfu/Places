//
//  PlaceTypeCell.m
//  Places
//
//  Created by Iris Fu on 8/11/22.
//

#import "PlaceTypeCell.h"

@implementation PlaceTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = 16;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
}

@end
