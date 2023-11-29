
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FontSizeLayer.h"

@implementation FontSizeLayer

+ (BOOL)needsDisplayForKey:(NSString *)inKey {
    if ([inKey isEqualToString:@"fontSize"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:inKey];
    }
}

- (id)fontSize {
    return [self.delegate fontSize];
}

- (void)setFontSize:(CGFloat)inFontSize {
    [self.delegate setFontSize:inFontSize];
}

@end
