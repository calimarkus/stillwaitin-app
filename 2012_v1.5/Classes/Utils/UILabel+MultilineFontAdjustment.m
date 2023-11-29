#import "UILabel+MultilineFontAdjustment.h"

@implementation UILabel (UILabelMultilineFontAdjustment)

- (void)adjustMultilineFontsize
{
	[self adjustMultilineFontsize:25.0 minimum:10.0];
}

- (void)adjustMultilineFontsize:(float)maxFontSize minimum:(float)minFontSize
{
	if(nil == self.text) 
		return;

	CGSize constraintSize;
	CGSize labelSize;
	
	for(float i = maxFontSize; i >= minFontSize; i -= 1.0)
	{
		self.font = [self.font fontWithSize:i];
		
		constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
		labelSize = [self.text sizeWithFont:self.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		
		if(labelSize.height <= self.frame.size.height)
			break;
	}
}

- (void)alignTop
{
    CGSize fontSize = [self.text sizeWithFont:self.font];
	
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;
	
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
	
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
	
    for(int i = 1; i < newLinesToPad; i++)
    {
        self.text = [self.text stringByAppendingString:@"\n"];
    }
}

@end
