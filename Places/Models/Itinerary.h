//
//  Itinerary.h
//  Places
//
//  Created by Iris Fu on 7/14/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Itinerary : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSObject *author; // PFUser type
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) NSString *lodgingDetails;
@property (nonatomic, strong) NSString *travelDetails;
@property (nonatomic, strong) NSArray *placesToGo;
@property (nonatomic, strong) NSNumber *estimatedCost;

// array of String, each elem representing an activity, e.g. ["Created by Senem on July 21st, 2022", "Viewed by Iris on July 21st, 2022"]
@property (nonatomic, strong) NSArray *activityHistory;

@end

NS_ASSUME_NONNULL_END
