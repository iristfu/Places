//
//  Itinerary.m
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import "Itinerary.h"

@implementation Itinerary

@dynamic name;
@dynamic author;
@dynamic image;
@dynamic startDate;
@dynamic endDate;
@dynamic lodgingDetails;
@dynamic travelDetails;
@dynamic placesToGo;
@dynamic estimatedCost;

+ (nonnull NSString *)parseClassName {
    return @"Itinerary";
}


@end
