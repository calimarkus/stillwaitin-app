#import <UIKit/UIKit.h>

// here you can define log level values
#define LOG_LEVEL_NONE		0
#define LOG_LEVEL_INFO		1
#define LOG_LEVEL_WARNING	2
#define LOG_LEVEL_ERROR		3
#define LOG_LEVEL_DEBUG		4

// setting the current log level
// for release
#ifdef _RELEASE
	#define LOG_LEVEL LOG_LEVEL_NONE
	#define LOG_TO_FILE nil
// for debug
#else
	#define LOG_LEVEL LOG_LEVEL_DEBUG
	//#define LOG_TO_FILE [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/default.log"]
	#define LOG_TO_FILE nil
#endif

// maximum file size of the log file in MB
#define LOG_TO_FILE_MAX_SIZE 50

// define the default log statement and entries
#define LOG_MESSAGE(title, text, ...)  {NSString* logString = [NSString stringWithFormat:@"%@ (%@): %@ (%d) - <%p>[%@ %@]: %@",												\
title,																																\
[NSDate date],	\
[[NSString stringWithUTF8String:__FILE__] lastPathComponent],																		\
__LINE__ ,																															\
self,																																\
NSStringFromClass([self class]),																									\
NSStringFromSelector(_cmd),																											\
[NSString stringWithFormat:(text), ##__VA_ARGS__ ]																					\
];																																	\
CFShow(logString);																													\
if (LOG_TO_FILE != nil) {																											\
if (![[NSFileManager defaultManager] fileExistsAtPath:LOG_TO_FILE]) {															\
[[NSFileManager defaultManager] createFileAtPath:LOG_TO_FILE contents:nil attributes:nil];									\
}																																\
NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:LOG_TO_FILE];												\
unsigned long long size = [fileHandle seekToEndOfFile];																			\
if (size/1024/1024 < LOG_TO_FILE_MAX_SIZE)																								\
{																																\
[fileHandle writeData:[[NSString stringWithFormat:@"%@ \n",logString] dataUsingEncoding:NSUTF8StringEncoding]];				\
[fileHandle synchronizeFile];																								\
}																																\
[fileHandle closeFile];																											\
}}


#if LOG_LEVEL >= 1
#define LogInfo( s, ... ) LOG_MESSAGE(@"LOG-INFO",s , ##__VA_ARGS__)
#else
#define LogInfo( s, ... ) 
#endif 

#if LOG_LEVEL >= 2
#define LogWarning( s, ... ) LOG_MESSAGE(@"LOG-WARNING",s , ##__VA_ARGS__)
#else
#define LogWarning( s, ... ) 
#endif 

#if LOG_LEVEL >= 3
#define LogError( s, ... ) LOG_MESSAGE(@"LOG-ERROR",s , ##__VA_ARGS__)
#else
#define LogError( s, ... ) 
#endif 

#if LOG_LEVEL >= 4
#define LogDebug( s, ... ) LOG_MESSAGE(@"LOG-DEBUG",s , ##__VA_ARGS__)
#else
#define LogDebug( s, ... ) 
#endif