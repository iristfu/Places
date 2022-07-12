//
//  Place.h
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Place : PFObject
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSNumber *priceLevel;
@property (nonatomic, strong) NSArray *coordinates; // [latitude, longitude]

@end

NS_ASSUME_NONNULL_END
