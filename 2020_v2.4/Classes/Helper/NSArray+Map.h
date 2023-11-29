//
//  NSArray+Map.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

@interface NSArray<__covariant ObjectType> (Map)

- (NSArray *)map:(id(^)(ObjectType obj))block;
- (NSArray<ObjectType> *)filter:(BOOL(^)(ObjectType obj))block;

@end
