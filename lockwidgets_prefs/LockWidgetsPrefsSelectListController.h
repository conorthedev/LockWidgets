#import <Preferences/PSViewController.h>
#import <objc/runtime.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface NSExtension : NSObject

+ (instancetype)extensionWithIdentifier:(NSString *)identifier error:(NSError **)error;

- (void)beginExtensionRequestWithInputItems:(NSArray *)inputItems completion:(void (^)(NSUUID *requestIdentifier))completion;

- (int)pidForRequestIdentifier:(NSUUID *)requestIdentifier;
- (void)cancelExtensionRequestWithIdentifier:(NSUUID *)requestIdentifier;

- (void)setRequestCancellationBlock:(void (^)(NSUUID *uuid, NSError *error))cancellationBlock;
- (void)setRequestCompletionBlock:(void (^)(NSUUID *uuid, NSArray *extensionItems))completionBlock;
- (void)setRequestInterruptionBlock:(void (^)(NSUUID *uuid))interruptionBlock;

@end

@interface CPDistributedMessagingCenter : NSObject {
	NSString* _centerName;
	NSLock* _lock;
	unsigned _sendPort;
	CFMachPortRef _invalidationPort;
	NSOperationQueue* _asyncQueue;
	CFRunLoopSourceRef _serverSource;
	NSString* _requiredEntitlement;
	NSMutableDictionary* _callouts;
}
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(id)_initWithServerName:(NSString*)serverName;
// inherited: -(void)dealloc;
-(NSString*)name;
-(unsigned)_sendPort;
-(void)_serverPortInvalidated;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
-(NSDictionary*)sendMessageAndReceiveReplyName:(NSString*)name userInfo:(NSDictionary*)info;
-(NSDictionary*)sendMessageAndReceiveReplyName:(NSString*)name userInfo:(NSDictionary*)info error:(NSError**)error;
-(void)sendMessageAndReceiveReplyName:(NSString*)name userInfo:(NSDictionary*)info toTarget:(id)target selector:(SEL)selector context:(void*)context;
-(BOOL)_sendMessage:(id)message userInfo:(id)info receiveReply:(id*)reply error:(id*)error toTarget:(id)target selector:(SEL)selector context:(void*)context;
-(BOOL)_sendMessage:(id)message userInfoData:(id)data oolKey:(id)key oolData:(id)data4 receiveReply:(id*)reply error:(id*)error;
-(void)runServerOnCurrentThread;
-(void)runServerOnCurrentThreadProtectedByEntitlement:(id)entitlement;
-(void)stopServer;
-(void)registerForMessageName:(NSString*)messageName target:(id)target selector:(SEL)selector;
-(void)unregisterForMessageName:(NSString*)messageName;
-(void)_dispatchMessageNamed:(id)named userInfo:(id)info reply:(id*)reply auditToken:(audit_token_t*)token;
-(BOOL)_isTaskEntitled:(audit_token_t*)entitled;
-(id)_requiredEntitlement;
@end

@interface WGWidgetInfo : NSObject {

	NSPointerArray* _registeredWidgetHosts;
	struct {
		unsigned didInitializeWantsVisibleFrame : 1;
	}  _widgetInfoFlags;
	BOOL _wantsVisibleFrame;
	NSString* _sdkVersion;
	NSExtension* _extension;
	long long _initialDisplayMode;
	long long _largestAllowedDisplayMode;
	NSString* _displayName;
	CGSize _preferredContentSize;
}
@property (assign,nonatomic) CGSize preferredContentSize;                                                            //@synthesize preferredContentSize=_preferredContentSize - In the implementation block
@property (setter=_setDisplayName:,nonatomic,copy) NSString * displayName;                                           //@synthesize displayName=_displayName - In the implementation block
@property (getter=_sdkVersion,nonatomic,copy,readonly) NSString * sdkVersion;                                        //@synthesize sdkVersion=_sdkVersion - In the implementation block
@property (assign,setter=_setLargestAllowedDisplayMode:,nonatomic) long long largestAllowedDisplayMode;              //@synthesize largestAllowedDisplayMode=_largestAllowedDisplayMode - In the implementation block
@property (assign,setter=_setWantsVisibleFrame:,nonatomic) BOOL wantsVisibleFrame;                                   //@synthesize wantsVisibleFrame=_wantsVisibleFrame - In the implementation block
@property (nonatomic,readonly) NSExtension * extension;                                                              //@synthesize extension=_extension - In the implementation block
@property (nonatomic,copy,readonly) NSString * widgetIdentifier; 
@property (setter=_setIcon:,nonatomic,retain) UIImage * icon;                                                      
@property (nonatomic,readonly) double initialHeight; 
@property (nonatomic,readonly) long long initialDisplayMode;                                                         //@synthesize initialDisplayMode=_initialDisplayMode - In the implementation block
+(id)_productVersion;
+(double)maximumContentHeightForCompactDisplayMode;
+(id)widgetInfoWithExtension:(id)arg1 ;
+(void)_updateRowHeightForContentSizeCategory;
-(id)_icon;
-(NSString *)widgetIdentifier;
-(id)_queue_iconWithFormat:(int)arg1 forWidgetWithIdentifier:(id)arg2 extension:(id)arg3 ;
-(int)_outlineVariantForScale:(double)arg1 ;
-(id)_queue_iconWithOutlineForWidgetWithIdentifier:(id)arg1 extension:(id)arg2 ;
-(void)_resetIconsImpl;
-(void)_resetIcons;
-(id)widgetInfoWithExtension:(id)arg1 ;
-(void)_setLargestAllowedDisplayMode:(long long)arg1 ;
-(BOOL)isLinkedOnOrAfterSystemVersion:(id)arg1 ;
-(void)requestSettingsIconWithHandler:(/*^block*/id)arg1 ;
-(void)requestIconWithHandler:(/*^block*/id)arg1 ;
-(id)_queue_iconFromWidgetBundleForWidgetWithIdentifier:(id)arg1 extension:(id)arg2 ;
-(void)_requestIcon:(BOOL)arg1 withHandler:(/*^block*/id)arg2 ;
-(id)_sdkVersion;
-(double)initialHeight;
-(BOOL)wantsVisibleFrame;
-(void)_setWantsVisibleFrame:(BOOL)arg1 ;
-(void)registerWidgetHost:(id)arg1 ;
-(void)updatePreferredContentSize:(CGSize)arg1 forWidgetHost:(id)arg2 ;
-(long long)initialDisplayMode;
-(long long)largestAllowedDisplayMode;
-(id)initWithExtension:(id)arg1 ;
-(CGSize)preferredContentSize;
-(void)setPreferredContentSize:(CGSize)arg1 ;
-(NSExtension *)extension;
@end

@class NSDate;
@interface WGCalendarWidgetInfo : WGWidgetInfo {

	NSDate* _date;
}
@property (setter=_setDate:,nonatomic,retain) NSDate * date;              //@synthesize date=_date - In the implementation block
+(BOOL)isCalendarExtension:(id)arg1 ;
-(void)_setDate:(NSDate*)arg1 ;
-(id)_queue_iconWithFormat:(int)arg1 forWidgetWithIdentifier:(id)arg2 extension:(id)arg3 ;
-(id)_queue_iconWithOutlineForWidgetWithIdentifier:(id)arg1 extension:(id)arg2 ;
-(void)_resetIconsImpl;
-(id)initWithExtension:(id)arg1 ;
-(void)_handleSignificantTimeChange:(id)arg1 ;
-(NSDate *)date;
@end

@interface LockWidgetsPrefsSelectListController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSArray *tableData; // holds the table data (title)
@property (nonatomic, strong) NSMutableArray *tableDetailData; // holds the table data (detail text)

- (void)refreshList;
@end