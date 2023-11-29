//
//  ListTableCell.m
//  StillWaitin
//
//  Created by devmob on 04.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "ListTableCell.h"


@implementation ListTableCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		CGRect ltvcFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, 62.0);
		mListTableContentView = [[ListTableContentView alloc] initWithFrame:ltvcFrame];
		[self.contentView addSubview:mListTableContentView];
    }
    return self;
}

- (void)setEntry:(Entry *)entry
{
	mListTableContentView.entry = entry;
	
	[mListTableContentView setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	[mListTableContentView setEditing:editing];
}

- (void)setHighlighted:(BOOL)editing animated:(BOOL)animated
{
	[super setHighlighted:editing animated:animated];
	[mListTableContentView setHighlighted:editing];
}

- (void)dealloc
{
	[mListTableContentView release];
    [super dealloc];
}


@end
