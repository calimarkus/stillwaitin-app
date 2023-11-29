//
//  ListViewController.h
//  StillWaitin
//
//  Created by devmob on 22.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddViewController.h"
#import "DetailViewController.h"
#import "ListTotalSumBar.h"

@interface ListViewController : UIViewController <UITableViewDelegate,
                                                  UITableViewDataSource,
                                                  UIAlertViewDelegate>
{
	CGRect mViewRectangle;
	
	// navbar
	UIImageView *mNavigationBarImageView;
	
	// table view shows all stored entries
	UITableView *mListTableView;
	
	// total sum
	ListTotalSumBar* mTotalSumBar;
	
	// array stores all saved entries sorted by person
	NSMutableArray *mEntryArray;
	
	// last selected cell
	NSIndexPath *mSelectedCellIndexPath;
	
	// currency formatter
	NSNumberFormatter *mCurrencyFormatter;
	
	// info for first usage
	UIImageView* mArrowImageView;
	UILabel* mInfoLabel;
}

@property (nonatomic, retain) NSMutableArray *allentries;

- (id)initWithFrame:(CGRect)frame;

- (void) reloadData;
- (void) reloadDataWithTableReload: (BOOL) tableReload;
- (void) updateTotalSumBar;

- (void)createCurrencyFormatter;
- (void)addUi;
- (void)loadStoredEntries;
- (void)removeEntryByIndex:(NSIndexPath *)indexPath;

- (void)addListenerForDetailDeletion;
- (void)removeSelectedEntry:(id)sender;
- (BOOL)hasEntries;
- (void)addInitialInfoIfNoEntriesAvailable;
- (void)removeInitialInfoIfEntriesAvailable;

- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForSection: (NSInteger) section;
- (UITableViewCell *)tableView:(UITableView *)tableView footerCellForSection: (NSInteger) section;

@end


int comparePersons( id obj1, id obj2, void *context );