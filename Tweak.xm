#import "Tweak.h"
#include <substrate.h>
#import <rocketbootstrap/rocketbootstrap.h>

bool enabled = YES;

NSString *identifier = @"com.apple.BatteryCenter.BatteryWidget";
SBDashBoardNotificationAdjunctListViewController *controller;

@interface MYMessagingCenter : NSObject {
 	CPDistributedMessagingCenter * _messagingCenter;
 }
 @end

 @implementation MYMessagingCenter

 + (void)load {
 	[self sharedInstance];
 }

 + (instancetype)sharedInstance {
 	static dispatch_once_t once = 0;
 	__strong static id sharedInstance = nil;
 	dispatch_once(&once, ^{
 		sharedInstance = [self new];
 	});
 	return sharedInstance;
 }

 - (instancetype)init {
 	if ((self = [super init])) {
 		_messagingCenter = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];

 		[_messagingCenter runServerOnCurrentThread];
 		[_messagingCenter registerForMessageName:@"getWidgets" target:self selector:@selector(handleGetWidgets:withUserInfo:)];
		[_messagingCenter registerForMessageName:@"getInfo" target:self selector:@selector(handleGetInfo:withUserInfo:)];
	 }

 	return self;
 }

 - (NSDictionary *)handleGetWidgets:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	if([name isEqualToString:@"getWidgets"]) {
 		WGWidgetDiscoveryController *wdc = [[%c(WGWidgetDiscoveryController) alloc] init];
    	[wdc beginDiscovery];

		return @{@"widgets" : wdc.disabledWidgetIdentifiers};
	}
	return nil;
 }

 - (NSDictionary *)handleGetInfo:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	if([name isEqualToString:@"getInfo"]) {
		WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:userInfo[@"identifier"]];

		return @{@"displayName" : widgetInfo.displayName};
	}
	return nil;
 }

 @end

%hook SBDashBoardNotificationAdjunctListViewController
%property (nonatomic, retain) WGWidgetPlatterView *widgetView;
%property (nonatomic, retain) WGWidgetHostingViewController *widgetHost;

-(BOOL)hasContent {
    return enabled;
}

-(void)viewDidLoad {
    %orig;

	if(enabled) {
		controller = self;
		UIStackView *stackView = [self valueForKey:@"_stackView"];

   	 	NSError *error;
    	NSExtension *extension = [NSExtension extensionWithIdentifier:identifier error:&error];

    	WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

		if([identifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [identifier isEqualToString:@"com.apple.mobilecal.widget"]) {
			WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
			NSDate *now = [NSDate date];
			[widgetInfoCal setValue:now forKey:@"_date"];
			self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil];
		} else {
			self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil];
		}

		CGRect frame = (CGRect){{0, 0}, {355, 300}};
    
		WGWidgetPlatterView *platterView = [[%c(WGWidgetPlatterView) alloc] initWithFrame:frame andCornerRadius:13.0f];

		if (%c(MTMaterialView)) {
			@try {
				[platterView setValue:@1 forKey:@"_recipe"];
				[platterView setValue:@2 forKey:@"_options"];
			} @catch (NSException *e) {
				// do nothing for NSUndefinedKeyException
			}
			// go through each subview to find material view (usually the first element)
			for (UIView *view in [platterView subviews]) {
				if ([view isKindOfClass:%c(MTMaterialView)]) {
					MTMaterialView *materialView = (MTMaterialView *)view;
					if ([materialView respondsToSelector:@selector(setFinalRecipe:options:)]) {
						[materialView setFinalRecipe:1 options:2];
					} else {
						[view removeFromSuperview];

						@autoreleasepool {
							// little performance heavy but I couldn't figure out a way to overwrite recipe once view is created
							materialView = [%c(MTMaterialView) materialViewWithRecipe:1 options:2];
							materialView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
							[materialView _setCornerRadius:13.0f];
							[platterView insertSubview:materialView atIndex:0];
						}
					}
					break;
				}
			}
		}
		[platterView setWidgetHost:self.widgetHost];
		[platterView setShowMoreButtonVisible:NO];
		[stackView addArrangedSubview:platterView];
		self.widgetView = platterView;

        [NSLayoutConstraint activateConstraints:@[
            [self.widgetView.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [self.widgetView.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [self.widgetView.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [self.widgetView.heightAnchor constraintEqualToConstant:widgetInfo.initialHeight + 40]
        ]];
	} else {
		[self.widgetView removeFromSuperview];
	}
}

-(void)_updatePresentingContent {
    %orig;

	if(enabled) {
    	UIStackView *stackView = [self valueForKey:@"_stackView"];
    	[stackView removeArrangedSubview:self.widgetView];
    	[stackView addArrangedSubview:self.widgetView];

		[self reloadData];
	} else {
		[self.widgetView removeFromSuperview];		
	}
}

-(void)_insertItem:(id)arg1 animated:(BOOL)arg2 {
    %orig;

	if(enabled) {
    	UIStackView *stackView = [self valueForKey:@"_stackView"];
    	[stackView removeArrangedSubview:self.widgetView];
    	[stackView addArrangedSubview:self.widgetView];

		[self reloadData];
	} else {
		[self.widgetView removeFromSuperview];
	}
}

-(BOOL)isPresentingContent {
    return enabled;
}

%new
-(void)reloadData {
	NSError *error;
	NSExtension *extension = [NSExtension extensionWithIdentifier:identifier error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([identifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [identifier isEqualToString:@"com.apple.mobilecal.widget"]) {
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
		[widgetInfoCal setValue:now forKey:@"_date"];
		self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil];
		[self.widgetView setWidgetHost:self.widgetHost];
	} else {
		self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil];
		[self.widgetView setWidgetHost:self.widgetHost];
	}
}

%end

%hook SBDashBoardMediaControlsViewController

-(void)viewDidAppear:(BOOL)animated {
	%orig;
	if (controller && enabled) [controller reloadData];
}

%end

static void loadPrefs() {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.conorthedev.lockwidgets.prefs.plist"];

	enabled = [settings objectForKey:@"kEnabled"] ? [[settings objectForKey:@"kEnabled"] boolValue] : YES;
}

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("me.conorthedev.lockwidgets.prefs/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
