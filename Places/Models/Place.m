//
//  Place.m
//  Places
//
//  Created by Iris Fu on 7/11/22.
//

#import "Place.h"

@implementation Place

@dynamic placeID;
@dynamic name;
@dynamic address;
@dynamic photos;
@dynamic rating;
@dynamic categories;
@dynamic lat;
@dynamic lng;
@dynamic favoriteCount;

+ (nonnull NSString *)parseClassName {
    return @"Place";
}

@end
