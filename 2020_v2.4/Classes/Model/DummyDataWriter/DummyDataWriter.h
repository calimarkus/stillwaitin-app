//
//  DummyDataWriter.h
//  StillWaitin
//
//

#ifdef kDEBUG

@class RealmEntry;

@interface DummyDataWriter : NSObject

+ (NSArray<RealmEntry *> *)defaultScreenshotEntries;

+ (NSArray<RealmEntry *> *)layoutTestEntries;

+ (NSArray *)createDummyDataWithPersonCount:(NSInteger)personCount
                     maxEntryCountPerPerson:(NSInteger)maxEntryCountPerPerson
                               maxDebtValue:(NSInteger)maxDebtValue
                       shouldUseLegacyModel:(BOOL)shouldUseLegacyModel;

@end

#endif
