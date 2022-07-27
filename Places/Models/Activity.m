//
//  Activity.m
//  Places
//
//  Created by Iris Fu on 7/27/22.
//

#import "Activity.h"

@implementation Activity

@dynamic activityType;
@dynamic user;
@dynamic timestamp;

+ (nonnull NSString *)parseClassName {
    return @"Activity";
}

@end
