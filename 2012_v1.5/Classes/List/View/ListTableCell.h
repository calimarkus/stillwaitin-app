//
//  ListTableCell.h
//  StillWaitin
//
//  Created by devmob on 04.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTableContentView.h"


@interface ListTableCell : UITableViewCell
{
	ListTableContentView *mListTableContentView;
}

- (void)setEntry:(Entry *)entry;

@end
