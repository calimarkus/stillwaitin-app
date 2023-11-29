//
//  ListViewDataSourceContentType.m
//  StillWaitin
//

#import "ListViewDataSourceContentType.h"

#import "SWSettings.h"

ListViewDataSourceContentType DefaultDataSourceContentType(void) {
  return ([[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsKeyOpenToAll]
          ? ListViewDataSourceContentTypeAll
          : ListViewDataSourceContentTypeActive);
}
