//
//  ListViewDataSourceContentType.h
//  StillWaitin
//

typedef NS_ENUM(NSInteger, ListViewDataSourceContentType) {
  ListViewDataSourceContentTypeActive,
  ListViewDataSourceContentTypeArchivedEntries,
  ListViewDataSourceContentTypeArchivedGroups,
  ListViewDataSourceContentTypeAll,
};

extern ListViewDataSourceContentType DefaultDataSourceContentType(void);
