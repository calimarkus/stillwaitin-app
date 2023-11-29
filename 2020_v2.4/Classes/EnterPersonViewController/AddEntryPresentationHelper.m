//
//  AddEntryPresentationHelper.m
//  StillWaitin
//

#import "AddEntryPresentationHelper.h"

#import "AddressBookContact.h"
#import "DetailViewController.h"
#import "EnterPersonViewController.h"
#import "RealmEntry.h"
#import "RealmEntryGroup.h"

@implementation AddEntryPresentationHelper

+ (void)presentAddEntryFlowForExistingEntryGroup:(RealmEntryGroup *)entryGroup
                                onViewController:(UIViewController *)viewController {
  RealmEntry *firstEntry = entryGroup.entries.firstObject;
  AddressBookContact *existingContact = [[AddressBookContact alloc] initWithFullName:firstEntry.fullName
                                                                               email:firstEntry.email
                                                                         phoneNumber:firstEntry.phoneNumber
                                                                        lastUsedDate:nil
                                                                       allowDeletion:NO];
  DetailViewController *addController = [[DetailViewController alloc] initWithAddresBookContact:existingContact];
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    [viewController.navigationController pushViewController:addController animated:YES];
  } else {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addController];
    navController.navigationBar.translucent = NO;
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [viewController presentViewController:navController animated:YES completion:nil];
  }
}

+ (void)presentAddEntryFlowForNewPersonOnViewController:(UIViewController *)viewController {
  // search person mode
  EnterPersonViewController* enterPersonController = [[EnterPersonViewController alloc] init];
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    [viewController.navigationController pushViewController:enterPersonController animated:YES];
    
    __weak typeof(enterPersonController) weakController = enterPersonController;
    enterPersonController.didSelectPersonBlock = ^(AddressBookContact *contact){
      DetailViewController *addController = [[DetailViewController alloc] initWithAddresBookContact:contact];
      NSMutableArray *viewControllers = [viewController.navigationController.viewControllers mutableCopy];
      [viewControllers removeObject:weakController];
      [viewControllers addObject:addController];
      [viewController.navigationController setViewControllers:viewControllers animated:YES];
    };
  } else {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:enterPersonController];
    navController.navigationBar.translucent = NO;
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [viewController presentViewController:navController animated:YES completion:nil];
    
    enterPersonController.didSelectPersonBlock = ^(AddressBookContact *contact){
      DetailViewController *addController = [[DetailViewController alloc] initWithAddresBookContact:contact];
      [navController setViewControllers:@[addController] animated:YES];
      [addController.navigationItem setLeftBarButtonItem:nil];
    };
  }
}

@end
