//
// ListViewControllerFactory.m
// Still Waitin
//

#import "ListViewControllerFactory.h"

#import "EntryListViewController.h"
#import "ListViewDataSourceContentType.h"
#import "PersonListViewController.h"
#import "SWSettings.h"

UIViewController<ListViewController> *createListViewController(void) {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsSingleListMode]) {
    return [[EntryListViewController alloc] initWithPersonName:nil
                                                   contentType:DefaultDataSourceContentType()];
  } else {
    return [[PersonListViewController alloc] init];
  }
}
