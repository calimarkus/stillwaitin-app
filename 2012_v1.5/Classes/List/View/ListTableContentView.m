//
//  ListTableContentView.m
//  StillWaitin
//
//  Created by devmob on 28.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "ListTableContentView.h"
#import <CoreGraphics/CGAffineTransform.h>


@implementation ListTableContentView

@synthesize entry = mEntry;
@synthesize highlighted;
@synthesize editing;

- (id)initWithFrame:(CGRect)frame
{	
	if(self = [super initWithFrame:frame])
	{
		self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (void) dealloc
{
	self.entry = nil;
	[super dealloc];
}


- (void)drawRect:(CGRect)rect
{	
#define LEFT_COLUMN_WIDTH 140
	
#define MAIN_FONT_SIZE 16
#define MIN_MAIN_FONT_SIZE 14
#define DATE_FONT_SIZE 12
#define VALUE_FONT_SIZE 21
	
	// Color and font for the description
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	
	// Color and font for the date
	UIColor *dateTextColor = nil;
	UIFont *dateFont = [UIFont boldSystemFontOfSize:DATE_FONT_SIZE];
	
	// Color and font for the value
	UIFont *valueFont = [UIFont boldSystemFontOfSize:VALUE_FONT_SIZE];
	
	// shadow color
	UIColor *mainShadowTextColor = nil;
	UIColor *highlightedShadowColor = [UIColor colorWithWhite: 0 alpha: 0.25];
	
	NSString * backgroundName;
	NSString * disclosureBtnName;
	NSString * notificationIconName;
	
	
	// Choose font color based on highlighted state.
	if (self.highlighted)
	{
		mainTextColor = [UIColor colorWithWhite: 174/255.0 alpha: 1.0];
		mainShadowTextColor = [UIColor colorWithWhite: 1 alpha: 0.4]; //kCOLOR_SHADOW_MAIN;
		dateTextColor = [UIColor colorWithRed: 104/255.0 green: 116/255.0 blue: 121/255.0 alpha: 1.0];
		backgroundName = @"tablecell_62_bg_selected.png";
		disclosureBtnName = @"tablecell_disclosure_selected.png";
		notificationIconName = @"notification_icon_list_selected.png";
	}
	else
	{
		mainTextColor = kCOLOR_GREEN_MAIN;
		mainShadowTextColor = [UIColor colorWithWhite: 1 alpha: 0.4]; //kCOLOR_SHADOW_MAIN;
		dateTextColor = kCOLOR_GRAY_LIGHT;
		backgroundName = @"tablecell_62_bg.png";
		disclosureBtnName = @"tablecell_disclosure.png";
		notificationIconName = @"notification_icon_list.png";
	}
	
	// TODO: move instance to singleton
	// setup number formatter
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setMaximumFractionDigits:2];
	[currencyFormatter setMinimumFractionDigits:2];
	
	NSString *currencyString = [currencyFormatter stringFromNumber:mEntry.value];

	[currencyFormatter release];
	
	// rect for value
	CGRect valueRect = CGRectMake(176, 18, 115, 20);
	CGSize valueSize = [currencyString sizeWithFont: valueFont];
	float descriptionWidth = LEFT_COLUMN_WIDTH;
	descriptionWidth += (valueRect.size.width - valueSize.width);
	
	// draw background
	CGPoint point = CGPointMake(0.0, 0.0);
	UIImage *backgroundImage = [UIImage imageNamed: backgroundName];
	[backgroundImage drawAtPoint:point];
	
	// if not showing delete button
	if(!self.editing)
	{
		// draw shadows
		if (self.highlighted)
		{	
			[highlightedShadowColor set];
			//[currencyString drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:valueFont minFontSize:VALUE_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
			[currencyString drawInRect: CGRectMake(valueRect.origin.x-2, valueRect.origin.y-2, valueRect.size.width, valueRect.size.height) withFont:valueFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
		}
		else
		{
			[mainShadowTextColor set];
			//[currencyString drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:valueFont minFontSize:VALUE_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
			[currencyString drawInRect: valueRect withFont:valueFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
		}

		[mainTextColor set];
		//[currencyString drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:valueFont minFontSize:VALUE_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		[currencyString drawInRect: CGRectMake(valueRect.origin.x-1, valueRect.origin.y-1, valueRect.size.width, valueRect.size.height) withFont:valueFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
		
		
		// draw disclosure button
		UIImage * image = [UIImage imageNamed:disclosureBtnName];
		point = CGPointMake(self.frame.size.width - image.size.width - 12, self.frame.size.height/2 - image.size.height/2);
		[image drawAtPoint:point];
	}
	
	
	// change description rect based on notification image
	UIImage* notificationImage;
	if ([mEntry isMemberOfClass: [Entry4 class]])
	{
		Entry4* e = (Entry4*)mEntry; 
		if (e.notification != nil)
		{
			notificationImage = [UIImage imageNamed: notificationIconName];
			descriptionWidth -= notificationImage.size.width + 10;
		}
	}
	
	// draw description text
	Boolean entryHasDescription = mEntry.description != nil && mEntry.description.length > 0;
	if (entryHasDescription)
	{
		if (self.highlighted)
		{
			[highlightedShadowColor set];
			CGPoint point = CGPointMake(21.0, 11.0);
			[mEntry.description drawAtPoint:point forWidth:descriptionWidth withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		}
		else
		{
			[mainShadowTextColor set];
			CGPoint point = CGPointMake(23.0, 13.0);
			[mEntry.description drawAtPoint:point forWidth:descriptionWidth withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		}
		
		[mainTextColor set];
		point = CGPointMake(22.0, 12.0);
		[mEntry.description drawAtPoint:point forWidth:descriptionWidth withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		if ([mEntry isMemberOfClass: [Entry4 class]])
		{
			Entry4* e = (Entry4*)mEntry;
			if (e.notification != nil)
			{
				CGSize size = [e.description sizeWithFont: mainFont minFontSize: MIN_MAIN_FONT_SIZE actualFontSize: NULL forWidth: descriptionWidth lineBreakMode: UILineBreakModeTailTruncation];
				CGPoint point = CGPointMake(size.width+30.0,15.0);
				[notificationImage drawAtPoint:point];
			}
		}
	}
	
	// draw date text using date formatter
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:NSLocalizedString(@"keyDatePattern", nil)];
	NSString *localizedDateString = [dateFormatter stringFromDate:mEntry.date];
	
	UIFont * usefont;
	UIColor * usecolor;
	
	if (entryHasDescription)
	{
		point = CGPointMake(23.0, 34.0);
		usefont = dateFont;
		usecolor = dateTextColor;
		
	}
	else
	{
		point = CGPointMake(23.0, 21.0);
		usefont = [UIFont boldSystemFontOfSize: 17];
		usecolor = mainTextColor;
	}
	
	if (self.highlighted)
	{
		[highlightedShadowColor set];
		[localizedDateString drawAtPoint:CGPointMake(point.x-2, point.y-2) forWidth:LEFT_COLUMN_WIDTH withFont:usefont minFontSize:DATE_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
	else
	{
		[mainShadowTextColor set];
		[localizedDateString drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:usefont minFontSize:DATE_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	}
	
	// draw notification icon behind date, if no description is set
	if ([mEntry isMemberOfClass: [Entry4 class]])
	{
		Entry4* e = (Entry4*)mEntry;
		if (!entryHasDescription && e.notification != nil)
		{
			CGSize size = [localizedDateString sizeWithFont: usefont minFontSize: DATE_FONT_SIZE actualFontSize: NULL forWidth: LEFT_COLUMN_WIDTH lineBreakMode: UILineBreakModeTailTruncation];
			CGPoint point = CGPointMake(size.width+35,23.0);
			[notificationImage drawAtPoint:point];
		}
	}
		
	[usecolor set];
	point = CGPointMake(point.x-1, point.y-1);
	[localizedDateString drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:usefont minFontSize:DATE_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
	
	if (!self.highlighted)
	{
		// draw debt direction indicator
		UIImage *image = nil;
		if(DebtDirectionIn == mEntry.direction)
		{
			image = [UIImage imageNamed:@"tablecell_indicator_green.png"];
		}
		else
		{
			image = [UIImage imageNamed:@"tablecell_indicator_red.png"];
		}
		point = CGPointMake(0, 0);
		[image drawAtPoint:point];
	}
	
}

- (void)setHighlighted:(BOOL)lit 
{
	// If highlighted state changes, need to redisplay.
	if (highlighted != lit)
	{
		highlighted = lit;	
		[self setNeedsDisplay];
	}
}

- (void)setEditing:(BOOL)lit 
{
	// If editing state changes, need to redisplay.
	if (editing != lit)
	{
		editing = lit;	
		[self setNeedsDisplay];
	}
}


@end
