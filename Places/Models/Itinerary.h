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

@end

NS_ASSUME_NONNULL_END
