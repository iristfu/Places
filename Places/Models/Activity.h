//
//  Activity.h
//  Places
//
//  Created by Iris Fu on 7/27/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Activity : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *activityType; // e.g. created, viewed, edited
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSDate *timestamp;

@end

NS_ASSUME_NONNULL_END
