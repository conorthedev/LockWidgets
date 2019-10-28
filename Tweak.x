#import <UIKit/UIKit.h>

@interface NSExtension : NSObject

+ (instancetype)extensionWithIdentifier:(NSString *)identifier error:(NSError **)error;

- (void)beginExtensionRequestWithInputItems:(NSArray *)inputItems completion:(void (^)(NSUUID *requestIdentifier))completion;

- (int)pidForRequestIdentifier:(NSUUID *)requestIdentifier;
- (void)cancelExtensionRequestWithIdentifier:(NSUUID *)requestIdentifier;

- (void)setRequestCancellationBlock:(void (^)(NSUUID *uuid, NSError *error))cancellationBlock;
- (void)setRequestCompletionBlock:(void (^)(NSUUID *uuid, NSArray *extensionItems))completionBlock;
- (void)setRequestInterruptionBlock:(void (^)(NSUUID *uuid))interruptionBlock;

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

@interface WGWidgetHostingViewController : UIViewController {
    	WGWidgetInfo* _widgetInfo;
}
- (id)initWithWidgetInfo:(id)arg1 delegate:(id)arg2 host:(id)arg3;
- (WGWidgetInfo *)widgetInfo;
@end


@interface WGWidgetListItemViewController : UIViewController 
{
	NSString* _widgetIdentifier;
    WGWidgetHostingViewController* _widgetHost;
}

@property(nonatomic, copy, readonly) NSString *widgetIdentifier;
@property (nonatomic,readonly) WGWidgetHostingViewController* widgetHost;

- (id)initWithWidgetIdentifier:(id)arg1;
- (id)widgetHost;

@end

@interface SBDashBoardNotificationAdjunctListViewController : UIViewController
{
    UIStackView *_stackView;
}

@property(nonatomic, retain) UIView *widgetView;

- (void)adjunctListModel:(id)arg1 didAddItem:(id)arg2;
- (void)adjunctListModel:(id)arg1 didRemoveItem:(id)arg2;
- (void)_didUpdateDisplay;
- (CGSize)sizeToMimic;
- (void)_insertItem:(id)arg1 animated:(BOOL)arg2;
- (void)_removeItem:(id)arg1 animated:(BOOL)arg2;
- (BOOL)isPresentingContent;

@end

%hook SBDashBoardNotificationAdjunctListViewController
%property (nonatomic, retain) UIView *widgetView;

-(BOOL)hasContent {
    return YES;
}

-(void)viewDidLoad {
    %orig;
	UIStackView *stackView = [self valueForKey:@"_stackView"];

    NSError *error;
    NSExtension *extension = [NSExtension extensionWithIdentifier:@"com.apple.UpNextWidget.extension" error:&error];
    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];
    
	WGWidgetListItemViewController *widget = [[%c(WGWidgetListItemViewController) alloc] initWithWidgetIdentifier:@"com.apple.UpNextWidget.extension"];
    WGWidgetHostingViewController *widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:widget];
    
    [widget setValue:widgetHost forKey:@"_widgetHost"];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
	view.backgroundColor = [UIColor redColor];
	[self addChildViewController:widget];
	[view addSubview:widget.view];
	widget.view.frame = view.frame;
	widget.view.translatesAutoresizingMaskIntoConstraints = NO;
	[widget didMoveToParentViewController:self];
	[stackView addArrangedSubview:view];

	[NSLayoutConstraint activateConstraints:@[
            [widget.view.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [widget.view.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [widget.view.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [widget.view.heightAnchor constraintEqualToConstant:150]
    ]];

}

-(void)_updatePresentingContent {
    %orig;
    UIStackView *stackView = [self valueForKey:@"_stackView"];
    [stackView removeArrangedSubview:self.widgetView];
    [stackView addArrangedSubview:self.widgetView];
}

-(void)_insertItem:(id)arg1 animated:(BOOL)arg2 {
    %orig;
    UIStackView *stackView = [self valueForKey:@"_stackView"];
    [stackView removeArrangedSubview:self.widgetView];
    [stackView addArrangedSubview:self.widgetView];
}

-(BOOL)isPresentingContent {
    return YES;
}

%end
