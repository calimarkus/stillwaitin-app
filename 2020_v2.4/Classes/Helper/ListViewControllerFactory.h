//
// ListViewControllerFactory.h
// Still Waitin
//

#import <UIKit/UIKit.h>

@protocol ListViewController;

CF_EXTERN_C_BEGIN

UIViewController<ListViewController> *createListViewController(void);

CF_EXTERN_C_END
