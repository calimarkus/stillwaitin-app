#import "FontSizeTextField.h"
#import "FontSizeLayer.h"


#import <QuartzCore/QuartzCore.h>

@implementation FontSizeTextField

+ (Class)layerClass
{
    return [FontSizeLayer class];
}

- (CGFloat)fontSize
{
    return self.font.pointSize;
}

- (void)setFontSize:(CGFloat)inFontSize
{
    self.font = [UIFont fontWithName:self.font.fontName size:inFontSize];    
}

- (void) runFontSizeAnimation: (NSTimer*) timer
{
	NSArray * userInfo = [timer userInfo];
	NSNumber * size = [userInfo objectAtIndex: 0];
	NSNumber * duration = [userInfo objectAtIndex: 1];
	
	[self animateFontSizeToSize: [size floatValue] withDuration: [duration floatValue]];
}

- (void) animateFontSizeToSize: (CGFloat) size withDuration: (CGFloat) duration
{
	NSString * animationkey = @"fontsizeanimation";
	
	[self.layer removeAnimationForKey: animationkey];
	
    CABasicAnimation *theAnimation=[CABasicAnimation animation];
	theAnimation.keyPath = @"fontSize";
	theAnimation.duration=duration;
	theAnimation.toValue = [NSNumber numberWithFloat:size];
	theAnimation.fillMode = kCAFillModeBoth; 
	theAnimation.removedOnCompletion = YES;
    theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	[self.layer addAnimation:theAnimation forKey: animationkey];
}

- (void) animateFontSizeToSize: (CGFloat) size withDuration: (CGFloat) duration andDelay: (CGFloat) delay
{
	NSMutableArray * userInfo = [NSMutableArray array];
	[userInfo addObject: [NSNumber numberWithFloat: size]];
	[userInfo addObject: [NSNumber numberWithFloat: duration]];
	
	[NSTimer scheduledTimerWithTimeInterval: delay target: self selector:@selector(runFontSizeAnimation:) userInfo:userInfo repeats:NO];
}


@end
