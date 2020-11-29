#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

#define LogDebug(message, ...) \
	NSLog((@"[LockWidgets] (DEBUG) " message), ##__VA_ARGS__)
#define LogInfo(message, ...) \
	NSLog((@"[LockWidgets] (INFO) " message), ##__VA_ARGS__)
#define LogError(message, ...) \
	NSLog((@"[LockWidgets] (ERROR) " message), ##__VA_ARGS__)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface NSUserDefaults (Private)
- (instancetype)_initWithSuiteName:(NSString *)suiteName
						 container:(NSURL *)container;
@end

@interface NSExtension : NSObject

+ (instancetype)extensionWithIdentifier:(NSString *)identifier error:(NSError **)error;

- (void)beginExtensionRequestWithInputItems:(NSArray *)inputItems completion:(void (^)(NSUUID *requestIdentifier))completion;

- (int)pidForRequestIdentifier:(NSUUID *)requestIdentifier;
- (void)cancelExtensionRequestWithIdentifier:(NSUUID *)requestIdentifier;

- (void)setRequestCancellationBlock:(void (^)(NSUUID *uuid, NSError *error))cancellationBlock;
- (void)setRequestCompletionBlock:(void (^)(NSUUID *uuid, NSArray *extensionItems))completionBlock;
- (void)setRequestInterruptionBlock:(void (^)(NSUUID *uuid))interruptionBlock;

@end