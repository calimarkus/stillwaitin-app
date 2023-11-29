//
//  ListViewController.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ListViewControllerDelegate <NSObject>
- (void)listViewControllerDidUpdateToTotalSum:(double)totalSum;
@end

@protocol ListViewController <NSObject>
@property (nonatomic, weak, nullable) id<ListViewControllerDelegate> delegate;
@property (nonatomic, strong, nullable) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END

