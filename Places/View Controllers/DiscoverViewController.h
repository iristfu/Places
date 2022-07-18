//
//  DiscoverViewController.h
//  Places
//
//  Created by Iris Fu on 7/10/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddPlacesToGoViewDelegate

- (void) finishedAddingPlacesToGo:(NSArray *)placesToGo;

@end

@interface DiscoverViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResults;
@property (weak, nonatomic) NSString *viewFrom; // string representing which view triggered the discover view
@property (nonatomic, weak) id<AddPlacesToGoViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *placesToGo;

@end

NS_ASSUME_NONNULL_END
