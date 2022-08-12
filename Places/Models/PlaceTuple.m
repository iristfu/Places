//
//  PlaceTuple.m
//  Places
//
//  Created by Iris Fu on 8/1/22.
//

#import "PlaceTuple.h"
#import "Place.h"

@implementation PlaceTuple

- (instancetype)initWithOrigin:(Place *)origin andDestination:(Place *)destination {
    self = [super init];
    if (self) {
        _origin = origin;
        _destination = destination;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithOrigin:self.origin
                                              andDestination:self.destination];
}

- (BOOL)isEqual:(id)object {
    if (object == nil) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[PlaceTuple class]]) {
        return NO;
    }
    PlaceTuple *other = (PlaceTuple *)object;
    return [self.origin isEqual:other.origin] && [self.destination isEqual:other.destination];
}

- (NSUInteger)hash {
    return [self.origin hash] ^ [self.destination hash] ^ 238473643724;
}


@end
