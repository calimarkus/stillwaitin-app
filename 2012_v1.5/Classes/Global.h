#import "StillWaitinAppDelegate.h"

// debugging
#ifndef kDEBUG
#define	kDEBUG 1
#endif

#if kDEBUG
#define NSLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSLog( s, ... )
#endif

// common
#define SCREENSIZE                      [UIScreen mainScreen].bounds.size

#define kSTATUS_BAR_HEIGHT				20.0
#define kNAVIGATION_BAR_HEIGHT			44.0
#define kTAB_BAR_HEIGHT					49.0

// table
#define kTABLE_HEADER_HEIGHT			25.0
#define kTABLE_FOOTER_HEIGHT			25.0

#define kTABLE_SPACING_HEADER			30.0
#define kTABLE_SPACING_FOOTER			10.0

// colors
#define kCOLOR_GREEN_MAIN               [UIColor colorWithRed:14/255.0 green:42/255.0 blue:52/255.0 alpha:1.0]
#define kCOLOR_GRAY_LIGHT               [UIColor colorWithWhite:92/255.0 alpha:1.0]

// shadows
#define kCOLOR_SHADOW_MAIN              [UIColor colorWithWhite:1.0 alpha:0.6]
#define kSIZE_SHADOW_MAIN               CGSizeMake(1,1)
#define kCOLOR_SHADOW_TABLE_HEADER		[UIColor colorWithWhite:0.0 alpha:0.6]
#define kSIZE_SHADOW_TABLE_HEADER		CGSizeMake(-1,-1)
#define kCOLOR_SHADOW_DETAIL_DATE       [UIColor colorWithWhite:0.0 alpha:0.2]
#define kSIZE_SHADOW_DETAIL_DATE        CGSizeMake(-1,-1)

// data
#define kENTRY_USER_DEFAULTS_KEY				@"entry"
#define kCUSTOM_PERSONS_USER_DEFAULTS_KEY		@"customPerson"
#define kCUSTOM_PERSONS_DELETE_INTERVAL			1209600 // 1209600 sec = 14 days / 14*24*60*60

#define kKEY_SETTING_SHOW_TOTALSUM				@"kKEY_SETTING_SHOW_TOTALSUM"
#define kKEY_SORTING_ORDER_ALPHABETICALLY		@"kKEY_SORTING_ORDER_ALPHABETICALLY"
#define kKEY_APP_START_COUNT					@"kKEY_APP_START_COUNT_V1.35"

// shortcut
#define GET_PATH(filename) [[NSBundle mainBundle] pathForResource:filename ofType:nil]


