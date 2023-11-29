//
//  SettingsPickFromListViewController.h
//  StillWaitin
//
//

@interface ListOption : NSObject
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, assign, readonly) NSInteger value;
+ (instancetype)optionWithDisplayName:(NSString *)displayName value:(NSInteger)value;
@end

@interface SettingsSelectListOptionViewController : UIViewController

- (instancetype)initWithOptions:(NSArray<ListOption *> *)options
                   defaultValue:(NSInteger)defaultValue
                userDefaultsKey:(NSString *)userDefaultsKey
              didSelectCallback:(void(^)(void))didSelectCallback;

@end
