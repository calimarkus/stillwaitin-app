//
//  StillWaitin_Tests.m
//  StillWaitin Tests
//
//

#import "EntriesImporterExporter.h"
#import "RealmEntry.h"

#import <XCTest/XCTest.h>

@interface ImportExportTests : XCTestCase
@end

@implementation ImportExportTests

- (void)testImport
{
  NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleEntries_en" ofType:@"json"];
  NSArray *results = [EntriesImporterExporter importDataFromFilePath:filePath];

  XCTAssert(results.count == 3, @"Import failed.");

  RealmEntry *entry = results.firstObject;
  XCTAssert([entry.fullName isEqualToString:@"Martin"]);
  XCTAssert([entry.entryDescription isEqualToString:@"Cheeseburger @ The Bird"]);
  XCTAssert(entry.location.latitude = 52.50458117385626);
  XCTAssert(entry.location.longitude = 13.4479177691024);
  XCTAssert([entry.value isEqualToNumber:@20]);
  XCTAssert(entry.fullName = @"Martin");
}

@end
