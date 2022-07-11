//
//  DiscoverViewController.h
//  Places
//
//  Created by Iris Fu on 7/10/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DiscoverViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResults;

@end

NS_ASSUME_NONNULL_END
