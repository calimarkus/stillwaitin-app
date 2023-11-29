//
//  EmptyListView.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmptyListView : UIView

- (void)setVisibleAnimated:(BOOL)isVisible;
- (void)updateForScrollContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
