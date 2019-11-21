#import <rocketbootstrap/rocketbootstrap.h>

@interface WGWidgetDiscoveryController : NSObject
- (void)beginDiscovery;
- (id)visibleWidgetIdentifiersForGroup:(id)arg1;
- (id)enabledWidgetIdentifiersForAllGroups;
- (id)disabledWidgetIdentifiers;
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

@interface CPDistributedMessagingCenter : NSObject
{
	NSString *_centerName;
	NSLock *_lock;
	unsigned _sendPort;
	CFMachPortRef _invalidationPort;
	NSOperationQueue *_asyncQueue;
	CFRunLoopSourceRef _serverSource;
	NSString *_requiredEntitlement;
	NSMutableDictionary *_callouts;
}
+ (CPDistributedMessagingCenter *)centerNamed:(NSString *)serverName;
- (id)_initWithServerName:(NSString *)serverName;
// inherited: -(void)dealloc;
- (NSString *)name;
- (unsigned)_sendPort;
- (void)_serverPortInvalidated;
- (BOOL)sendMessageName:(NSString *)name userInfo:(NSDictionary *)info;
- (NSDictionary *)sendMessageAndReceiveReplyName:(NSString *)name userInfo:(NSDictionary *)info;
- (NSDictionary *)sendMessageAndReceiveReplyName:(NSString *)name userInfo:(NSDictionary *)info error:(NSError **)error;
- (void)sendMessageAndReceiveReplyName:(NSString *)name userInfo:(NSDictionary *)info toTarget:(id)target selector:(SEL)selector context:(void *)context;
- (BOOL)_sendMessage:(id)message userInfo:(id)info receiveReply:(id *)reply error:(id *)error toTarget:(id)target selector:(SEL)selector context:(void *)context;
- (BOOL)_sendMessage:(id)message userInfoData:(id)data oolKey:(id)key oolData:(id)data4 receiveReply:(id *)reply error:(id *)error;
- (void)runServerOnCurrentThread;
- (void)runServerOnCurrentThreadProtectedByEntitlement:(id)entitlement;
- (void)stopServer;
- (void)registerForMessageName:(NSString *)messageName target:(id)target selector:(SEL)selector;
- (void)unregisterForMessageName:(NSString *)messageName;
- (void)_dispatchMessageNamed:(id)named userInfo:(id)info reply:(id *)reply auditToken:(audit_token_t *)token;
- (BOOL)_isTaskEntitled:(audit_token_t *)entitled;
- (id)_requiredEntitlement;
@end