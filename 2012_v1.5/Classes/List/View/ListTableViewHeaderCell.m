//
//  ListTableHeaderView.m
//  StillWaitin
//
//  Created by devmob on 02.06.10.
//

#import "ListTableViewHeaderCell.h"


@implementation ListTableViewHeaderCell

@dynamic title;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		NSInteger yoffset = kTABLE_SPACING_HEADER;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];

		// add table header background
		mBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableheader_bg.png"]];
		mBackgroundImageView.frame = CGRectMake(0, yoffset, 320, kTABLE_HEADER_HEIGHT);
		[self.contentView addSubview:mBackgroundImageView];
		
		mTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yoffset, 320, kTABLE_HEADER_HEIGHT)];
		mTitleLabel.backgroundColor = [UIColor clearColor];
		mTitleLabel.font = [UIFont systemFontOfSize:13];
		mTitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		mTitleLabel.shadowColor = kCOLOR_SHADOW_TABLE_HEADER;
		mTitleLabel.shadowOffset = kSIZE_SHADOW_TABLE_HEADER;
		mTitleLabel.textAlignment = UITextAlignmentCenter;
		[self.contentView addSubview:mTitleLabel];
    }
    return self;
}

- (void)dealloc
{
	[mBackgroundImageView release];
	[mTitleLabel release];
	
    [super dealloc];
}

- (void) setTitle: (NSString *) title
{
	mTitleLabel.text = title;
}

- (NSString *) title
{
	return mTitleLabel.text;
}

@end
