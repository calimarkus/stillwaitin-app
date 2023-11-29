//
//  AddPersonSearchTableCell.m
//  StillWaitin
//
//  Created by devmob on 08.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddPersonSearchTableCell.h"

@implementation AddPersonSearchTableCell

- (id) initWithStyle: (UITableViewCellStyle) style reuseIdentifier: (NSString*) reuseIdentifier
{
	if ( (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier]) )
	{
		mPersonLabel = [[UILabel alloc] initWithFrame: CGRectMake(12, 0, self.contentView.frameWidth - 24, 48)];
        mPersonLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		mPersonLabel.backgroundColor = [UIColor clearColor];
		mPersonLabel.font = [UIFont boldSystemFontOfSize: 20];
		mPersonLabel.textColor = kCOLOR_GREEN_MAIN;
		mPersonLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview: mPersonLabel];
	}
	return self;
}

- (void)setHighlighted:(BOOL)editing animated:(BOOL)animated
{
	[super setHighlighted:editing animated:animated];
	
	if(YES == editing)
	{
		mPersonLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
		self.backgroundColor = [UIColor colorWithRed:14/255.0 green:42/255.0 blue:52/255.0 alpha:0.9];
	}
	else
	{
		mPersonLabel.textColor = kCOLOR_GREEN_MAIN;
		self.backgroundColor = [UIColor clearColor];
	}
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
	[super setSelected: selected animated: animated];
}

- (void) setPerson: (NSString*) person
{
	mPersonLabel.text = person;
}

- (NSString*) person
{
	return mPersonLabel.text;
}

- (void) dealloc
{
	[mPersonLabel release];
	
	[super dealloc];
}

@end