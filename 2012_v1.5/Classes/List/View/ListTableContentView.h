//
//  ListTableContentView.h
//  StillWaitin
//
//  Created by devmob on 28.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"


@interface ListTableContentView : UIView
{
	Entry *mEntry;
	
	BOOL highlighted;
	BOOL editing;
}
@property (nonatomic, retain) Entry *entry;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isEditing) BOOL editing;


@end
