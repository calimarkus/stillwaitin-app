//
//  UIImage+NSCoder.m
//  StillWaitin
//
//  Created by devmob on 20.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "UIImage+NSCoder.h"
#include <objc/runtime.h>
#define kEncodingKey        @"UIImage"


static void __attribute__((constructor)) initialize()
{
    @autoreleasepool
    {
        if (![[UIImage class] conformsToProtocol:@protocol(NSCoding)])
        {
            Class class = [UIImage class];
            
            if (!class_addMethod(class,
                                 @selector(initWithCoder:), 
                                 class_getMethodImplementation(class, @selector(initWithCoderForArchiver:)),
                                 protocol_getMethodDescription(@protocol(NSCoding), @selector(initWithCoder:), YES, YES).types))
            {
                //NSLog(@"Critical Error - [UIImage initWithCoder:] not defined.");
            }
            
            if (!class_addMethod(class,
                                 @selector(encodeWithCoder:),
                                 class_getMethodImplementation(class, @selector(encodeWithCoderForArchiver:)),
                                 protocol_getMethodDescription(@protocol(NSCoding), @selector(encodeWithCoder:), YES, YES).types))
            {
                //NSLog(@"Critical Error - [UIImage encodeWithCoder:] not defined.");
            }
        } 
    }
}


@implementation UIImage (NSCoding)

- (id)initWithCoderForArchiver:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        NSData *data = [decoder decodeObjectForKey:kEncodingKey];
        self = [self initWithData:data];
    }
    
    return self;
}

- (void)encodeWithCoderForArchiver:(NSCoder *)encoder
{
    NSData *data = UIImagePNGRepresentation(self);
    [encoder encodeObject:data forKey:kEncodingKey];
}

@end
