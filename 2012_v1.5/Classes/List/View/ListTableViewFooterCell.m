//
//  ListTableFooterView.m
//  StillWaitin
//
//  Created by devmob on 02.06.10.
//

#import "ListTableViewFooterCell.h"


@implementation ListTableViewFooterCell

@dynamic title;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{	
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];

		// add table header background
		mBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablefooter_bg.png"]];
		mBackgroundImageView.frame = CGRectMake(0,0, mBackgroundImageView.image.size.width, kTABLE_FOOTER_HEIGHT);
		[self.contentView addSubview:mBackgroundImageView];
		
		mTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 320, kTABLE_FOOTER_HEIGHT - 2)];
		mTitleLabel.backgroundColor = [UIColor clearColor];
		mTitleLabel.font = [UIFont systemFontOfSize:11.0];
		mTitleLabel.textColor = kCOLOR_GREEN_MAIN;
		mTitleLabel.shadowColor = [UIColor colorWithWhite: 1 alpha: 0.35]; //kCOLOR_SHADOW_MAIN;
		mTitleLabel.shadowOffset = kSIZE_SHADOW_MAIN;
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
