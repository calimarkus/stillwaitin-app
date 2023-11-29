//
//  MapAnnotation.h
//  StillWaitin
//
//  Created by devmob on 13.07.10.
//

#import "DDAnnotation.h"
#import "Entry.h"


@interface MapAnnotation : DDAnnotation
{
    Entry *_entry;
}

@property (nonatomic, retain) Entry *entry;

- (id)initWithEntry:(Entry*)entry;


@end

