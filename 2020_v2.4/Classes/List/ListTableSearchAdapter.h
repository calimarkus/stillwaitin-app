//
//  ListSearchView.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

#import "ListViewDataSourceContentType.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ListTableSearchAdapterDelegate
- (void)searchViewDidSelectContentType:(ListViewDataSourceContentType)selectedContentType;
- (void)searchViewDidUpdateSearchString:(NSString * _Nullable)searchString;
@end

@interface ListTableSearchAdapter : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTableView:(UITableView *)tableView
         applyContentTypeToGroups:(BOOL)applyContentTypeToGroups
    shouldHideContentTypeSelector:(BOOL)shouldHideContentTypeSelector
              selectedContentType:(ListViewDataSourceContentType)selectedContentType NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<ListTableSearchAdapterDelegate> delegate;

- (BOOL)isSearchBarFullyVisible;
- (void)tableViewDidScroll;
- (void)scrollTableViewToShowSearchView;
- (void)updateTargetContentOffsetAfterScrollingEnded:(inout CGPoint *)targetContentOffset;

@end

NS_ASSUME_NONNULL_END
