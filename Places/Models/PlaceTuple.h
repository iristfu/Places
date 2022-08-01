//
//  PlaceTuple.h
//  Places
//
//  Created by Iris Fu on 8/1/22.
//

#import <Foundation/Foundation.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaceTuple : NSObject

@property (nonatomic, strong) Place *origin;
@property (nonatomic, strong) Place *destination;

- (instancetype)initWithOrigin:(Place *)origin andDestination:(Place *)destination;

@end

NS_ASSUME_NONNULL_END
