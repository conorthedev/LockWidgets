#import "Tweak.h"
#import <Cephei/HBPreferences.h>
#import "LockWidgetsManager.h"
#import "UIKit+LockWidgets.h"

bool kEnabled = YES;
bool kShowScrollIndicator = YES;

HBPreferences *preferences;
NSMutableArray *widgetsArray;
NotificationController *notificationController;

/*
Messaging Center for Preferences to send and recieve information
*/

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
		[_messagingCenter registerForMessageName:@"getExtensionInfo" target:self selector:@selector(handleGetExtensionInfo:withUserInfo:)];
		[_messagingCenter registerForMessageName:@"getCurrentIdentifiers" target:self selector:@selector(handleGetCurrentIdentifiers:withUserInfo:)];
		[_messagingCenter registerForMessageName:@"setIdentifier" target:self selector:@selector(handleSetIdentifier:withUserInfo:)];
	}

 	return self;
}

// Handle the setting of identifiers
- (NSDictionary *)handleSetIdentifier:(NSString *)name withUserInfo:(NSDictionary *)userInfo  {
	widgetsArray = [widgetsArray mutableCopy];
	
	if(widgetsArray != nil) {
		if ([widgetsArray containsObject:userInfo[@"identifier"]]) {
    		[widgetsArray removeObject:userInfo[@"identifier"]];
		} else {
			[widgetsArray addObject:userInfo[@"identifier"]];
		}

		if(preferences != nil) {
			[preferences setObject:widgetsArray forKey:@"kWidgetIdentifiers"];
		}

		return @{@"status" : @YES};
	} else {
		return @{@"status" : @NO};
	}
}

// Returns a list of usable widgets
- (NSDictionary *)handleGetWidgets:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
	LockWidgetsManager *manager = [[LockWidgetsManager alloc] init];

 	WGWidgetDiscoveryController *wdc = [[%c(WGWidgetDiscoveryController) alloc] init];
    [wdc beginDiscovery];

	NSLog(@"[LockWidgets] (DEBUG) Available Extensions: %@", [manager allExtensionIdentifiers]);

	return @{@"widgets" : [manager allWidgetIdentifiers:wdc], @"extensions" : [manager allExtensionIdentifiers]};
}

// Returns the current identifier
- (NSDictionary *)handleGetCurrentIdentifiers:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
	return @{@"currentIdentifiers" : [widgetsArray mutableCopy]};
}

// Returns the display name and image of a widget from its identifier
- (NSDictionary *)handleGetInfo:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
	NSString *displayName = @"";
	NSData *imageData;

	NSError *error;
	NSExtension *extension = [NSExtension extensionWithIdentifier:userInfo[@"identifier"] error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([userInfo[@"identifier"] isEqualToString:@"com.apple.UpNextWidget.extension"] || [userInfo[@"identifier"] isEqualToString:@"com.apple.mobilecal.widget"]) {
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
		
		[widgetInfoCal setValue:now forKey:@"_date"];
		displayName = [widgetInfoCal displayName];
	} else {
		displayName = [widgetInfo displayName];
	}

	if(@available(iOS 13.0, *)) {
		WGWidgetHostingViewController *host	= [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil];

		if(!host.appBundleID) {
			return @{@"displayName" : [widgetInfo displayName]};
		}

		SBIconController *iconController = [NSClassFromString(@"SBIconController") sharedInstance];
  		SBIcon *icon = [iconController.model expectedIconForDisplayIdentifier:host.appBundleID];

		struct CGSize imageSize;
  			imageSize.height = 30;
  			imageSize.width = 30;

		struct SBIconImageInfo imageInfo;
  			imageInfo.size  = imageSize;
  			imageInfo.scale = [UIScreen mainScreen].scale;
  			imageInfo.continuousCornerRadius = 12;

		UIImage *image = [icon generateIconImageWithInfo:imageInfo];

		if (image == nil) {
			return @{@"displayName" : [widgetInfo displayName]};
		}

		imageData = UIImagePNGRepresentation(image);
	} else {
		return @{@"displayName" : [widgetInfo displayName]};
	}

	return @{@"displayName" : [widgetInfo displayName], @"imageData" : imageData};
}

// Returns the display name and image of an extension from its identifier
- (NSDictionary *)handleGetExtensionInfo:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
	LockWidgetsManager *manager = [[LockWidgetsManager alloc] init];
	NSDictionary *dictionary = [manager extensionInfoFromIdentifier:userInfo[@"identifier"]];

	NSLog(@"[LockWidgets] (DEBUG) Info for %@: %@", userInfo[@"identifier"], dictionary);

	return dictionary;
}

@end

%group group
%hook NotificationController

%property (strong, nonatomic) UICollectionView *collectionView;

%new - (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"widgetCell" forIndexPath:indexPath];
	NotificationController *me = (NotificationController*) self;
	int index = indexPath.row;
	NSString *identifier = [widgetsArray objectAtIndex:index];
	
	LockWidgetsManager *manager = [[LockWidgetsManager alloc] init];
	bool isExtension = [manager identifierIsValid:identifier];

	// Create the frame for the platterView
	CGRect frame = (CGRect){{0, 0}, {cell.contentView.bounds.size.width, cell.contentView.bounds.size.height}};	

	if(isExtension) {		
		NSDictionary *dictionary = [manager extensionInfoFromIdentifier:identifier];
		NSString *mainClassName = dictionary[@"mainClass"];

		UIViewController *extensionViewController = [[NSClassFromString(mainClassName) alloc] init];
		[extensionViewController loadView];
		extensionViewController.view.frame = frame;
		extensionViewController.view.layer.cornerRadius = 13.0f;
		[extensionViewController viewDidLoad];
		[extensionViewController viewWillAppear:NO];

		// Set the cell's contentView
		for (UIView *view in cell.contentView.subviews) {
			[view removeFromSuperview];
		}

		[cell.contentView addSubview:extensionViewController.view];

		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
      	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
      	blurEffectView.frame = cell.contentView.bounds;
      	blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		blurEffectView.layer.cornerRadius = 13.0f;
		blurEffectView.clipsToBounds = YES;

      	[cell.contentView insertSubview:blurEffectView atIndex: 0];

		return cell;
	} else {    
		// Parse the widget information from the identifier
		NSError *error;
		NSExtension *extension = [NSExtension extensionWithIdentifier:identifier error:&error];

		WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];
		WGWidgetHostingViewController *widgetHost;

		if([identifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [identifier isEqualToString:@"com.apple.mobilecal.widget"]) {
			// If it's a calander based widget, we need to do more setup for it to work correctly
			WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
			NSDate *now = [NSDate date];
				
			[widgetInfoCal setValue:now forKey:@"_date"];
			widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil];
		} else {
			widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil];
		}

		// Generate a platter view
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

		// Set the widgetHost for the platter view
		[platterView setWidgetHost:widgetHost];

		// Set the cell's contentView
		for (UIView *view in cell.contentView.subviews) {
			[view removeFromSuperview];
		}

		[cell.contentView addSubview:platterView];

		if(@available(iOS 13.0, *)) {
			// Fix on iOS 13 for the dark header being the old style
			MTMaterialView *header = MSHookIvar<MTMaterialView*>(platterView, "_headerBackgroundView");
			[header removeFromSuperview];
		}
		
		// Reload data at the end of initialization
		NSLog(@"[LockWidgets] (INFO) Attempting to reload data for: %@", identifier);

		if([identifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [identifier isEqualToString:@"com.apple.mobilecal.widget"]) {
			WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
			NSDate *now = [NSDate date];
			[widgetInfoCal setValue:now forKey:@"_date"];
			[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil]];
		} else {
			[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil]];
		}
		
		return cell;
	}
}

%new - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [widgetsArray count];
}

%new - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width - 5, 150);
}

%new - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 2.5, 0, 2.5);
}

%new - (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {   
    [collectionView scrollToItemAtIndexPath:context.nextFocusedIndexPath
                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                    animated:YES];
}

%new - (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
        minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}
	
-(void)viewDidLoad {
    %orig;

	NotificationController *me = (NotificationController*) self;

	if(kEnabled) {
		CGRect frame = (CGRect){{0, 0}, {me.view.frame.size.width, 150}};

		// Set the notificationController global variable for use later
		notificationController = me;

		// Get the stack view from me
        UIStackView *stackView = [me valueForKey:@"_stackView"];

		for (NSString *identifier in widgetsArray) {
			// Notepad Support
			if([identifier isEqualToString:@"com.neinzedd9.notepad.lockwidgetsextension"]) {
				NSLog(@"[LockWidgets] (DEBUG) Identifier is equal to com.neinzedd9.notepad.lockwidgetsextension");
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					[me.notepadContainerView removeFromSuperview];
				}
			} else {
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					[me initializeNotepadContainerView];
					[me showNotepad];
					[stackView addArrangedSubview:me.notepadContainerView];
				}
			}
		}

		// Create a flow layout
		UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
		
		// Setup the layout
		[layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
		layout.itemSize = CGSizeMake(355, 150);
		layout.minimumLineSpacing = 5;

		// Setup the collection view
    	me.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    	[me.collectionView setDataSource:me];
    	[me.collectionView setDelegate:me];

		// Remove the ugly background colour
		me.collectionView.backgroundColor = [UIColor clearColor];
		
		// Allow paging
		me.collectionView.pagingEnabled = YES;
		
		me.collectionView.contentSize = CGSizeMake(([widgetsArray count] * 355) + 100, 150);
		me.collectionView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
		
		// Set corner radius
		me.collectionView.layer.cornerRadius = 13.0f;

		// Disable selection
		me.collectionView.allowsSelection = NO;

		if(kShowScrollIndicator) {
			[me.collectionView setShowsHorizontalScrollIndicator:YES];
		} else {
			[me.collectionView setShowsHorizontalScrollIndicator:NO];
		}

		// Register cell class
    	[me.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"widgetCell"];

		// Add the collection view to the stackView
		[stackView addArrangedSubview:me.collectionView];

		// Add constraints
		[NSLayoutConstraint activateConstraints:@[
            [me.collectionView.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [me.collectionView.heightAnchor constraintEqualToConstant:150]
		]];
	} else {
		// Remove the collection view from the hierarchy
		[me.collectionView removeFromSuperview];
	}
}

// Fired whenever we need to update our content
-(void)_updatePresentingContent {
    %orig;

	NotificationController *me = (NotificationController*) self;

	if(kEnabled) {
		UIStackView *stackView = [me valueForKey:@"_stackView"];

		for (NSString *identifier in widgetsArray) {
			// Notepad Support
			if([identifier isEqualToString:@"com.neinzedd9.notepad.lockwidgetsextension"]) {
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					//todo a safeway to remove the view
				}
			} else {
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					[me initializeNotepadContainerView];
					[me showNotepad];
					[stackView addArrangedSubview:me.notepadContainerView];
				}
			}
		}

		[stackView removeArrangedSubview:me.collectionView];
    	[stackView addArrangedSubview:me.collectionView];

		[me.collectionView removeAllConstraints];
		
		// Add constraints
		[NSLayoutConstraint activateConstraints:@[
            [me.collectionView.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [me.collectionView.heightAnchor constraintEqualToConstant:150]
		]];

		[me.collectionView reloadData];
	}
}

-(void)viewDidAppear:(BOOL)animated {
    %orig(animated);

	NSLog(@"[LockWidgets] (INFO) Current Widgets: %@", widgetsArray);

	NotificationController *me = (NotificationController*) self;

	UIStackView *stackView = [me valueForKey:@"_stackView"];

	if(kEnabled) {
		for (NSString *identifier in widgetsArray) {
			// Notepad Support
			if([identifier isEqualToString:@"com.neinzedd9.notepad.lockwidgetsextension"]) {
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					//todo a safeway to remove the view
				}
			} else {
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					[me initializeNotepadContainerView];
					[me showNotepad];
					[stackView addArrangedSubview:me.notepadContainerView];
				}
			}
		}

		[stackView removeArrangedSubview:me.collectionView];
    	[stackView addArrangedSubview:me.collectionView];

		[me.collectionView removeAllConstraints];

		// Add constraints
		[NSLayoutConstraint activateConstraints:@[
            [me.collectionView.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [me.collectionView.heightAnchor constraintEqualToConstant:150]
		]];

		[me.collectionView reloadData];
	} else {
		// Remove the collection view from the hierarchy
		[stackView removeArrangedSubview:me.collectionView];
		[me.collectionView removeFromSuperview];
	}
}

// Fired whenever an item is being inserted into the view
-(void)_insertItem:(id)arg1 animated:(BOOL)arg2 {
    %orig;

	NotificationController *me = (NotificationController*) self;

	if(kEnabled) {
		UIStackView *stackView = [me valueForKey:@"_stackView"];

		for (NSString *identifier in widgetsArray) {
			// Notepad Support
			if([identifier isEqualToString:@"com.neinzedd9.notepad.lockwidgetsextension"]) {
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					//todo a safeway to remove the view
				}
			} else {
				if ([me respondsToSelector:@selector(notepadContainerView)]) {
					NSLog(@"[LockWidgets] (DEBUG) me responds to selector 'notepadContainerView'");
					[me initializeNotepadContainerView];
					[me showNotepad];
					[stackView addArrangedSubview:me.notepadContainerView];
				}
			}
		}

		[stackView removeArrangedSubview:me.collectionView];
    	[stackView addArrangedSubview:me.collectionView];

		[me.collectionView removeAllConstraints];
		
		// Add constraints
		[NSLayoutConstraint activateConstraints:@[
            [me.collectionView.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [me.collectionView.heightAnchor constraintEqualToConstant:150]
		]];

		[me.collectionView reloadData];
	}
}

// Tells springboard that we are presenting something when the tweak is enabled
-(BOOL)isPresentingContent {
    return kEnabled;
}

// Reloads data about a widget (when the identifier is changed, etc) 
%new -(void)reloadData:(NSString *)identifier indexPath:(NSIndexPath *)arg2 {
	NSLog(@"[LockWidgets] (INFO) (reloadData) Reloading Data for: %@", identifier);

	NotificationController *me = (NotificationController*) self;

	UICollectionViewCell *cell = [me.collectionView cellForItemAtIndexPath:arg2];
	UIView *contentView = cell.contentView;
	WGWidgetPlatterView *platterView = (WGWidgetPlatterView *)contentView;

	if(![platterView isKindOfClass:%c(WGWidgetPlatterView)]) {
		NSLog(@"[LockWidgets] (FATAL) platterView is not WGWidgetPlatterView!! returning before crash...");
		return;
	}

	// Parse the widget information from the identifier
	NSError *error;
	NSExtension *extension = [NSExtension extensionWithIdentifier:identifier error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([identifier isEqualToString:@"com.apple.UpNextWidget.extension"] || [identifier isEqualToString:@"com.apple.mobilecal.widget"]) {
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
		[widgetInfoCal setValue:now forKey:@"_date"];
		[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil]];
	} else {
		[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil]];
	}
}

%end
%end

void reloadPrefs() {
	NSLog(@"[LockWidgets] (INFO) Reloading Preferences...");

	preferences = [[HBPreferences alloc] initWithIdentifier:@"me.conorthedev.lockwidgets.prefs"];

    [preferences registerDefaults:@{
        @"kEnabled": @YES,
        @"kWidgetIdentifiers": [@[@"com.apple.BatteryCenter.BatteryWidget", @"com.apple.UpNextWidget.extension"] mutableCopy],
		@"kShowScrollIndicator": @YES
    }];

	[preferences registerBool:&kEnabled default:YES forKey:@"kEnabled"];
	[preferences registerBool:&kShowScrollIndicator default:YES forKey:@"kShowScrollIndicator"];
	[preferences registerObject:&widgetsArray default:[@[@"com.apple.BatteryCenter.BatteryWidget", @"com.apple.UpNextWidget.extension"] mutableCopy] forKey:@"kWidgetIdentifiers"];

	widgetsArray = [widgetsArray mutableCopy];

	NSLog(@"[LockWidgets] (INFO) Current Enabled State: %i", kEnabled);
	NSLog(@"[LockWidgets] (INFO) Current Scroll Identifier State: %i", kShowScrollIndicator);
	NSLog(@"[LockWidgets] (INFO) Current Identifiers: %@", widgetsArray);
}

%ctor {
	reloadPrefs();

	NSString *notificationControllerClass = @"SBDashBoardNotificationAdjunctListViewController";

	if(@available(iOS 13.0, *)) {
		notificationControllerClass = @"CSNotificationAdjunctListViewController";
	}

	%init(group, NotificationController = NSClassFromString(notificationControllerClass));

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, CFSTR("me.conorthedev.lockwidgets.prefs/ReloadPrefs"), NULL, kNilOptions);
}
