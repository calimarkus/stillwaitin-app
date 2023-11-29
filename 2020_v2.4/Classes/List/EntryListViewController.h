//
//  EntryListViewController.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

#import "ListViewController.h"
#import "ListViewDataSourceContentType.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntryListViewController : UIViewController <ListViewController>

- (instancetype)initWithPersonName:(NSString * _Nullable)personName
                       contentType:(ListViewDataSourceContentType)contentType;

@end

NS_ASSUME_NONNULL_END
