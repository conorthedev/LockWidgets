#import "Tweak.h"

bool kEnabled = YES;
NSString *kIdentifier = @"com.apple.BatteryCenter.BatteryWidget";

CSCombinedListViewController *combinedListController;
CSNotificationAdjunctListViewController *adjunctListController;

@interface LockWidgetsMessagingCenter : NSObject {
 	CPDistributedMessagingCenter * _messagingCenter;
}

@end

@implementation LockWidgetsMessagingCenter

+ (void)load 
{
	[self sharedInstance];
}

+ (instancetype)sharedInstance 
{
 	static dispatch_once_t once = 0;
	 
 	__strong static id sharedInstance = nil;
 	dispatch_once(&once, ^{
 		sharedInstance = [self new];
 	});

 	return sharedInstance;
}

- (instancetype)init 
{
 	if ((self = [super init])) {
 		_messagingCenter = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];

 		[_messagingCenter runServerOnCurrentThread];
 		[_messagingCenter registerForMessageName:@"getWidgets" target:self selector:@selector(handleGetWidgets:withUserInfo:)];
		[_messagingCenter registerForMessageName:@"getInfo" target:self selector:@selector(handleGetInfo:withUserInfo:)];
		[_messagingCenter registerForMessageName:@"setIdentifier" target:self selector:@selector(handleSetIdentifier:withUserInfo:)];
	}

 	return self;
}

- (NSDictionary *)handleSetIdentifier:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
	kIdentifier = userInfo[@"identifier"];

	if(combinedListController != nil) {
		[combinedListController reloadData];
	}

	if(adjunctListController != nil) {
		[adjunctListController reloadData];
	}

	return @{@"status" : @YES};
}

- (NSDictionary *)handleGetWidgets:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
 	WGWidgetDiscoveryController *wdc = [[%c(WGWidgetDiscoveryController) alloc] init];
    [wdc beginDiscovery];
	
	NSArray* widgetsArray = @[];
	widgetsArray = [widgetsArray arrayByAddingObjectsFromArray:wdc.disabledWidgetIdentifiers];
	widgetsArray = [widgetsArray arrayByAddingObjectsFromArray:wdc.enabledWidgetIdentifiersForAllGroups];

	return @{@"widgets" : widgetsArray};
}

- (NSDictionary *)handleGetInfo:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
	NSError *error;
	NSExtension *extension = [NSExtension extensionWithIdentifier:userInfo[@"identifier"] error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([userInfo[@"identifier"] isEqualToString:@"com.apple.UpNextWidget.extension"] || [userInfo[@"identifier"] isEqualToString:@"com.apple.mobilecal.widget"]) {
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
		
		[widgetInfoCal setValue:now forKey:@"_date"];
		return @{@"displayName" : [widgetInfoCal displayName]};
	} else {
		return @{@"displayName" : [widgetInfo displayName]};
	}
}

@end

%group ios13

%hook CSNotificationAdjunctListViewController

%property (nonatomic, retain) WGWidgetPlatterView *widgetView;
%property (nonatomic, retain) WGWidgetHostingViewController *widgetHost;

-(void)viewDidLoad 
{
    %orig;

	if(kEnabled) {
		NSLog(@"[LockWidgets] CSNotificationAdjunctListViewController#viewDidLoad");
		adjunctListController = self;

        UIStackView *stackView = [self valueForKey:@"_stackView"];

   	 	NSError *error;
    	NSExtension *extension = [NSExtension extensionWithIdentifier:kIdentifier error:&error];

    	WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

		if([kIdentifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [kIdentifier isEqualToString:@"com.apple.mobilecal.widget"]) {
			WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
			NSDate *now = [NSDate date];
			[widgetInfoCal setValue:now forKey:@"_date"];
			self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil];
		} else {
			self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil];
		}

		CGRect frame = (CGRect){{0, 0}, {355, 150}};
    
		WGWidgetPlatterView *platterView = [[%c(WGWidgetPlatterView) alloc] initWithFrame:frame];

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
							materialView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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

%new
-(void)reloadData 
{
	NSLog(@"[LockWidgets] Reloading Data for: %@", kIdentifier);
	NSError *error;
	NSExtension *extension = [NSExtension extensionWithIdentifier:kIdentifier error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([kIdentifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [kIdentifier isEqualToString:@"com.apple.mobilecal.widget"]) {
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

/*%hook SBDashBoardMediaControlsViewController

-(void)viewDidAppear:(BOOL)animated 
{
	%orig;
	if (controller && kEnabled) [controller reloadData];
}

%end*/
%end

%group old
%hook SBDashBoardNotificationAdjunctListViewController

%property (nonatomic, retain) WGWidgetPlatterView *widgetView;
%property (nonatomic, retain) WGWidgetHostingViewController *widgetHost;

-(BOOL)hasContent 
{
    return kEnabled;
}

-(void)viewDidLoad 
{
    %orig;

	if(kEnabled) {
		controller = self;
		UIStackView *stackView = [self valueForKey:@"_stackView"];

   	 	NSError *error;
    	NSExtension *extension = [NSExtension extensionWithIdentifier:kIdentifier error:&error];

    	WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

		if([kIdentifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [kIdentifier isEqualToString:@"com.apple.mobilecal.widget"]) {
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

		UILongPressGestureRecognizer *lpHandler = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hold)];
		lpHandler.minimumPressDuration = 0.5;
		[platterView addGestureRecognizer:lpHandler];

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

-(void)_updatePresentingContent 
{
    %orig;

	if(kEnabled) {
    	UIStackView *stackView = [self valueForKey:@"_stackView"];
    	[stackView removeArrangedSubview:self.widgetView];
    	[stackView addArrangedSubview:self.widgetView];

		[self reloadData];
	} else {
		[self.widgetView removeFromSuperview];		
	}
}

-(void)_insertItem:(id)arg1 animated:(BOOL)arg2 
{
    %orig;

	if(kEnabled) {
    	UIStackView *stackView = [self valueForKey:@"_stackView"];
    	[stackView removeArrangedSubview:self.widgetView];
    	[stackView addArrangedSubview:self.widgetView];

		[self reloadData];
	} else {
		[self.widgetView removeFromSuperview];
	}
}

-(BOOL)isPresentingContent 
{
    return kEnabled;
}

%new

- (void)hold {
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[%c(LWSelectWidgetController) alloc] init]];
	[self presentViewController:nav animated:YES completion:nil];
}

-(void)reloadData 
{
	NSError *error;
	NSExtension *extension = [NSExtension extensionWithIdentifier:kIdentifier error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([kIdentifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [kIdentifier isEqualToString:@"com.apple.mobilecal.widget"]) {
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

-(void)viewDidAppear:(BOOL)animated 
{
	%orig;
	if (controller && kEnabled) [controller reloadData];
}

%end
%end

%ctor {
	NSLog(@"[LockWidgets] (DEBUG) Current Enabled State: %i", kEnabled);
	NSLog(@"[LockWidgets] (DEBUG) Current identifier: %@", kIdentifier);

	if(@available(iOS 13.0, *)) {
		NSLog(@"[LockWidgets] (INFO) Current version is iOS 13!");
		%init(ios13)
	} else {
		NSLog(@"[LockWidgets] (INFO) Current version is iOS 12 or lower!");
		%init(old)
	}
}