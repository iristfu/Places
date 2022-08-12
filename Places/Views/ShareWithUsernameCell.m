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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

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
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [successAlert addAction:okAction];
    [self.delegate showAlert:successAlert];
}

@end
