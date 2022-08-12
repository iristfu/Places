//
//  Itinerary.h
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import <Parse/Parse.h>
#import "Activity.h"

NS_ASSUME_NONNULL_BEGIN

@interface Itinerary : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) NSString *lodgingDetails;
@property (nonatomic, strong) NSString *travelDetails;
@property (nonatomic, strong) NSMutableArray *placesToGo;
@property (nonatomic, strong) NSNumber *estimatedCost;
@property (nonatomic, strong) NSArray<Activity *> *activityHistory;
@property (nonatomic, strong) NSMutableArray *usersWithEditAccess;
@property (nonatomic, strong) NSMutableArray *usersWithViewAccess;

@end

NS_ASSUME_NONNULL_END
