//
//  ShareWithUsernameCell.m
//  Places
//
//  Created by Iris Fu on 8/4/22.
//

#import "ShareWithUsernameCell.h"

@implementation ShareWithUsernameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    NSLog(@"self.username in awakeFromNib is %@", self.username);
//    self.usernameLabel.text = self.username;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSArray<NSString *> *)getCurrentSharedItinerariesObjectIDs {
    NSMutableArray<NSString *> *objectIDs = [[NSMutableArray alloc] init];
    for (Itinerary *itinerary in self.user[@"sharedItineraries"]) {
        [objectIDs addObject:itinerary.objectId];
    }
    return [objectIDs copy];
}


- (IBAction)didTapShare:(id)sender {
    NSLog(@"tapped share on %@ with access permission %@", self.user.username, self.accessPermission);
    
    // update itinerary's usersWithEditAccess or usersWithViewAccess field
    [self.accessPermission isEqualToString:@"view"] ? [self.itinerary addObject:self.user forKey:@"usersWithViewAccess"] : [self.itinerary addObject:self.user forKey:@"usersWithEditAccess"];
    [self.itinerary saveInBackground];
    
    // give success alert
    NSLog(@"Will ideally show a success alert here");
    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                          message:[NSString stringWithFormat:@"Itinerary shared with %@ as %@er", self.user.username, self.accessPermission]
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
//    [self presentViewController:successAlert animated:YES completion:^{}];
    
//    // add itinerary to self.user's "shared with me" itineraries
//    NSArray<NSString *> *currentSharedItinerariesObjectIDS = [self getCurrentSharedItinerariesObjectIDs];
//    if (![currentSharedItinerariesObjectIDS containsObject:self.itinerary.objectId]) {
//        [self.user addObject:self.itinerary forKey:@"sharedItineraries"];
//        [self.user saveInBackground];
//    } else {
//        NSLog(@"%@ already has this shared itinerary", self.user.username);
//    }
//
//    // store access permissions
//    if ([self.accessPermission isEqualToString:@"view"]) {
//        [self.user addObject:self.itinerary.objectId forKey:@"viewOnlyItineraryIDs"];
//        [self.user saveInBackground];
//    }
}

@end
