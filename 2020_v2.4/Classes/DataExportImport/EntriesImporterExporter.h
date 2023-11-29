//
//  EntryStorage+DataExchange.h
//  StillWaitin
//
//

@class RealmEntry;

@interface EntriesImporterExporter : NSObject

// returns path of saved file, or nil
+ (NSString*)exportEntriesToDisk:(NSArray<RealmEntry *> *)entries
                 usingJsonFormat:(BOOL)usingJsonFormat;

// returns imported entries or nil, does not save entries
+ (NSArray<RealmEntry *> *)importDataFromFilePath:(NSString*)filePath;

@end
