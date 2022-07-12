//
//  Place.h
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Place : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;

@end

NS_ASSUME_NONNULL_END
