//
//  NSArray+Map.m
//  StillWaitin
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSArray *)map:(id(^)(id obj))block {
  NSMutableArray *newArray = [NSMutableArray array];
  for (id obj in self) {
    id newObj = block(obj);
    if (newObj != nil) {
      [newArray addObject:newObj];
    }
  }
  return newArray;
}

- (NSArray *)filter:(BOOL(^)(id obj))block {
  NSMutableArray *newArray = [NSMutableArray array];
  for (id obj in self) {
    if (block(obj)) {
      [newArray addObject:obj];
    }
  }
  return newArray;
}

@end
