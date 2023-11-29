//
//  ListTableHeaderView.h
//  StillWaitin
//
//  Created by devmob on 02.06.10.
//

#import <UIKit/UIKit.h>


@interface ListTableViewHeaderCell : UITableViewCell
{	
	UIImageView *mBackgroundImageView;
	UILabel *mTitleLabel;
}

@property (assign) NSString * title;

@end
