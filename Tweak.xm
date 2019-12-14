#import "Tweak.h"
#import <Cephei/HBPreferences.h>
#import "LockWidgetsManager.h"

bool kEnabled = YES;
HBPreferences *preferences;
bool previousDisabled = NO;

NSMutableArray *widgetsArray;

SBDashBoardNotificationAdjunctListViewController *controller;
CSNotificationAdjunctListViewController *adjunctListController;

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
		[_messagingCenter registerForMessageName:@"getCurrentIdentifier" target:self selector:@selector(handleGetCurrentIdentifier:withUserInfo:)];
		[_messagingCenter registerForMessageName:@"setIdentifier" target:self selector:@selector(handleSetIdentifier:withUserInfo:)];
	}

 	return self;
}

// Handle the setting of identifiers
- (NSDictionary *)handleSetIdentifier:(NSString *)name withUserInfo:(NSDictionary *)userInfo  {
	widgetsArray = [widgetsArray mutableCopy];
	NSLog(@"[LockWidgets] (DEBUG) userInfo.identifier: %@ | widgetsArray: %@ | widgetsArray class: %@", userInfo[@"identifier"], widgetsArray, NSStringFromClass([widgetsArray class]));
	
	if(widgetsArray != nil) {
		if ([widgetsArray containsObject:userInfo[@"identifier"]]) {
    		[widgetsArray removeObject:userInfo[@"identifier"]];
		} else {
			[widgetsArray addObject:userInfo[@"identifier"]];
		}

		if(preferences != nil) {
			[preferences setObject:widgetsArray forKey:@"kIdentifiersArray"];
		}

		return @{@"status" : @YES};
	} else {
		return @{@"status" : @NO};
	}
}

// Returns a list of usable widgets
- (NSDictionary *)handleGetWidgets:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
 	WGWidgetDiscoveryController *wdc = [[%c(WGWidgetDiscoveryController) alloc] init];
    [wdc beginDiscovery];

	return @{@"widgets" : [[[LockWidgetsManager alloc] init] allWidgetIdentifiers:wdc]};
}

// Returns the current identifier
- (NSDictionary *)handleGetCurrentIdentifier:(NSString *)name withUserInfo:(NSDictionary *)userInfo 
{
	return @{@"currentIdentifiers" : [widgetsArray mutableCopy]};
}

// Returns the display name of a widget from its identifier
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

/*
* iOS 13 code
*/
%group ios13
%hook CSNotificationAdjunctListViewController

%property (nonatomic, retain) WGWidgetPlatterView *widgetView;
%property (nonatomic, retain) WGWidgetHostingViewController *widgetHost;
%property (strong, nonatomic) UICollectionView *collectionView;

%new - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [widgetsArray count];
}

%new - (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
	int index = indexPath.row;
    
	// Parse the widget information from the identifier
	NSError *error;
    NSExtension *extension = [NSExtension extensionWithIdentifier:[widgetsArray objectAtIndex:index] error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.UpNextWidget.extension"] || [[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.mobilecal.widget"]) {
		// If it's a calander based widget, we need to do more setup for it to work correctly
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
			
		[widgetInfoCal setValue:now forKey:@"_date"];
		self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil];
	} else {
		self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil];
	}

	// Create the frame for the platterView
	CGRect frame = (CGRect){{0, 0}, {cell.contentView.bounds.size.width, cell.contentView.bounds.size.height}};
    
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
	[platterView setWidgetHost:self.widgetHost];

	// Set the cell's contentView
	for (UIView *view in cell.contentView.subviews) {
		[view removeFromSuperview];
	}

	[cell.contentView addSubview:platterView];

	// Fix on iOS 13 for the dark header being the old style
    MTMaterialView *header = MSHookIvar<MTMaterialView*>(platterView, "_headerBackgroundView");
    [header removeFromSuperview];

	// Add constraints
	[NSLayoutConstraint activateConstraints:@[
        [platterView.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor],
        [platterView.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:10],
        [platterView.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-10],
        [platterView.heightAnchor constraintEqualToConstant:widgetInfo.initialHeight + 40]
    ]];
	
	// Reload data at the end of initialization
	NSLog(@"[LockWidgets] (INFO) Attempting to reload data for: %@", [widgetsArray objectAtIndex:index]);

	if([[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.UpNextWidget.extension"] || [[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.mobilecal.widget"]) {
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
		[widgetInfoCal setValue:now forKey:@"_date"];
		[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil]];
	} else {
		[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil]];
	}
    
    return cell;
}

%new - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(355, 150);
}

%new - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

%new - (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{   
    [collectionView scrollToItemAtIndexPath:context.nextFocusedIndexPath
                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                    animated:YES];
}
	
-(void)viewDidLoad {
    %orig;

	if(kEnabled) {
		CGRect frame = (CGRect){{0, 0}, {355, 150}};

		// Set the adjunctListController global variable for use later
		adjunctListController = self;

		// Get the stack view from self
        UIStackView *stackView = [self valueForKey:@"_stackView"];

		// Create a flow layout
		UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
		
		// Setup the layout
		[layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
		layout.itemSize = CGSizeMake(355, 150);

		// Setup the collection view
    	self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    	[self.collectionView setDataSource:self];
    	[self.collectionView setDelegate:self];

		// Remove the ugly background colour
		self.collectionView.backgroundColor = [UIColor clearColor];
		
		// Allow paging
		self.collectionView.pagingEnabled = YES;
		self.collectionView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
		layout.minimumLineSpacing = 5;

		// Register cell class
    	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];

		// Add the collection view to the stackView
		[stackView addArrangedSubview:self.collectionView];

		// Add constraints
		[NSLayoutConstraint activateConstraints:@[
            [self.collectionView.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [self.collectionView.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [self.collectionView.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [self.collectionView.heightAnchor constraintEqualToConstant:150]
		]];

		[self.collectionView reloadData];
	} else {
		// Remove the collection view from the hierarchy
		[self.collectionView removeFromSuperview];
	}
}

// Fired whenever we need to update our content
-(void)_updatePresentingContent {
    %orig;

	if(kEnabled) {
		UIStackView *stackView = [self valueForKey:@"_stackView"];
		[stackView removeArrangedSubview:self.collectionView];
    	[stackView addArrangedSubview:self.collectionView];

		for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
			NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];

			NSLog(@"[LockWidgets] (INFO) Updating content for: %@ at index path: %ld", [cell description], (long) cellIndexPath.row);
			[self reloadData:[widgetsArray objectAtIndex:cellIndexPath.row] indexPath: cellIndexPath];
		}
	}
}

-(void)viewDidAppear:(BOOL)animated {
    %orig(animated);

	NSLog(@"[LockWidgets] (INFO) Current Widgets: %@", widgetsArray);

	UIStackView *stackView = [self valueForKey:@"_stackView"];

	if(kEnabled) {
		[stackView removeArrangedSubview:self.collectionView];
    	[stackView addArrangedSubview:self.collectionView];

		/*for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
			NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];

			[self.collectionView reloadItemsAtIndexPaths:@[cellIndexPath]];
		}*/
		[self.collectionView reloadData];
	} else {
		// Remove the collection view from the hierarchy
		[stackView removeArrangedSubview:self.collectionView];
		[self.collectionView removeFromSuperview];
	}
}

// Fired whenever an item is being inserted into the view
-(void)_insertItem:(id)arg1 animated:(BOOL)arg2 {
    %orig;

	if(kEnabled) {
		UIStackView *stackView = [self valueForKey:@"_stackView"];
		[stackView removeArrangedSubview:self.collectionView];
    	[stackView addArrangedSubview:self.collectionView];

		for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
			NSLog(@"[LockWidgets] (INFO) Inserting item and updating content for: %@", [cell description]);
			NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];
			[self reloadData:[widgetsArray objectAtIndex:cellIndexPath.row] indexPath: cellIndexPath];
		}
	}
}

// Tells springboard that we are presenting something when the tweak is enabled
-(BOOL)isPresentingContent {
    return kEnabled;
}

// Reloads data about a widget (when the identifier is changed, etc) 
%new -(void)reloadData:(NSString *)identifier indexPath:(NSIndexPath *)arg2 {
	NSLog(@"[LockWidgets] (INFO) (reloadData) Reloading Data for: %@", identifier);

	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:arg2];
	UIView *contentView = cell.contentView;
	WGWidgetPlatterView *platterView = (WGWidgetPlatterView *)contentView;
	NSAssert([platterView isKindOfClass:%c(WGWidgetPlatterView)], @"platterView is not WGWidgetPlatterView");

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

/*
* iOS 12 code
*/
%group old
%hook SBDashBoardNotificationAdjunctListViewController

%property (nonatomic, retain) WGWidgetPlatterView *widgetView;
%property (nonatomic, retain) WGWidgetHostingViewController *widgetHost;
%property (strong, nonatomic) UICollectionView *collectionView;

%new - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [widgetsArray count];
}

%new - (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
	int index = indexPath.row;
    
	// Parse the widget information from the identifier
	NSError *error;
    NSExtension *extension = [NSExtension extensionWithIdentifier:[widgetsArray objectAtIndex:index] error:&error];

    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];

	if([[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.UpNextWidget.extension"] || [[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.mobilecal.widget"]) {
		// If it's a calander based widget, we need to do more setup for it to work correctly
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
			
		[widgetInfoCal setValue:now forKey:@"_date"];
		self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil];
	} else {
		self.widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil];
	}

	// Create the frame for the platterView
	CGRect frame = (CGRect){{0, 0}, {355, 150}};
    
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
	[platterView setWidgetHost:self.widgetHost];

	// Set the cell's contentView
	for (UIView *view in cell.contentView.subviews) {
		[view removeFromSuperview];
	}

	[cell.contentView addSubview:platterView];

	// Fix on iOS 13 for the dark header being the old style
    MTMaterialView *header = MSHookIvar<MTMaterialView*>(platterView, "_headerBackgroundView");
    [header removeFromSuperview];

	// Add constraints
	[NSLayoutConstraint activateConstraints:@[
        [platterView.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor],
        [platterView.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:10],
        [platterView.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-10],
        [platterView.heightAnchor constraintEqualToConstant:widgetInfo.initialHeight + 40]
    ]];
	
	// Reload data at the end of initialization
	NSLog(@"[LockWidgets] (INFO) Attempting to reload data for: %@", [widgetsArray objectAtIndex:index]);

	if([[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.UpNextWidget.extension"] || [[widgetsArray objectAtIndex:index] isEqualToString:@"com.apple.mobilecal.widget"]) {
		WGCalendarWidgetInfo *widgetInfoCal = [[%c(WGCalendarWidgetInfo) alloc] initWithExtension:extension];
		NSDate *now = [NSDate date];
		[widgetInfoCal setValue:now forKey:@"_date"];
		[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfoCal delegate:nil host:nil]];
	} else {
		[platterView setWidgetHost:[[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:nil]];
	}
    
    return cell;
}

%new - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(360, 150);
}

-(BOOL)hasContent {
    return kEnabled;
}

-(void)viewDidLoad {
    %orig;

	if(kEnabled) {
		CGRect frame = (CGRect){{0, 0}, {355, 150}};

		// Set the controller global variable for use later
		controller = self;

		// Get the stack view from self
        UIStackView *stackView = [self valueForKey:@"_stackView"];

		// Create a flow layout
		UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
		
		// Setup the layout
		[layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
		layout.itemSize = CGSizeMake(360, 150);

		// Setup the collection view
    	self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    	[self.collectionView setDataSource:self];
    	[self.collectionView setDelegate:self];

		// Remove the ugly background colour
		self.collectionView.backgroundColor = [UIColor clearColor];
		
		// Allow paging
		self.collectionView.pagingEnabled = YES;

		// Register cell class
    	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];

		// Add the collection view to the stackView
		[stackView addArrangedSubview:self.collectionView];

		// Add constraints
		[NSLayoutConstraint activateConstraints:@[
            [self.collectionView.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [self.collectionView.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [self.collectionView.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [self.collectionView.heightAnchor constraintEqualToConstant:150]
		]];

		[self.collectionView reloadData];
	} else {
		// Remove the collection view from the hierarchy
		[self.collectionView removeFromSuperview];
	}
}

-(void)_updatePresentingContent {
    %orig;

	if(kEnabled) {
		UIStackView *stackView = [self valueForKey:@"_stackView"];
		[stackView removeArrangedSubview:self.collectionView];
    	[stackView addArrangedSubview:self.collectionView];

		for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
			NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];

			NSLog(@"[LockWidgets] (INFO) Updating content for: %@ at index path: %ld", [cell description], (long) cellIndexPath.row);
			[self reloadData:[widgetsArray objectAtIndex:cellIndexPath.row] indexPath: cellIndexPath];
		}
	}
}

-(void)viewDidAppear:(BOOL)animated {
    %orig(animated);

	UIStackView *stackView = [self valueForKey:@"_stackView"];

	if(kEnabled) {
		[stackView removeArrangedSubview:self.collectionView];
    	[stackView addArrangedSubview:self.collectionView];

		for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
			NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];

			[self.collectionView reloadItemsAtIndexPaths:@[cellIndexPath]];
		}
	} else {
		// Remove the collection view from the hierarchy
		[stackView removeArrangedSubview:self.collectionView];
		[self.collectionView removeFromSuperview];
	}
}

-(void)_insertItem:(id)arg1 animated:(BOOL)arg2 {
    %orig;

	if(kEnabled) {
		UIStackView *stackView = [self valueForKey:@"_stackView"];
		[stackView removeArrangedSubview:self.collectionView];
    	[stackView addArrangedSubview:self.collectionView];

		for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
			NSLog(@"[LockWidgets] (INFO) Inserting item and updating content for: %@", [cell description]);
			NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];
			[self reloadData:[widgetsArray objectAtIndex:cellIndexPath.row] indexPath: cellIndexPath];
		}
	}
}

-(BOOL)isPresentingContent 
{
    return kEnabled;
}

%new -(void)reloadData:(NSString *)identifier indexPath:(NSIndexPath *)arg2 {
	NSLog(@"[LockWidgets] (INFO) (reloadData) Reloading Data for: %@", identifier);

	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:arg2];
	UIView *contentView = cell.contentView;
	WGWidgetPlatterView *platterView = (WGWidgetPlatterView *)contentView;
	NSAssert([platterView isKindOfClass:%c(WGWidgetPlatterView)], @"platterView is not WGWidgetPlatterView");

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
	NSLog(@"[LockWidgets] (DEBUG) Reloading Preferences...");

	preferences = [[HBPreferences alloc] initWithIdentifier:@"me.conorthedev.lockwidgets.prefs"];

    [preferences registerDefaults:@{
        @"kEnabled": @YES,
        @"kIdentifiersArray": [@[@"com.apple.BatteryCenter.BatteryWidget", @"com.apple.WeatherAppTodayWidget"] mutableCopy]
    }];

	[preferences registerBool:&kEnabled default:YES forKey:@"kEnabled"];
	[preferences registerObject:&widgetsArray default:[@[@"com.apple.BatteryCenter.BatteryWidget", @"com.apple.WeatherAppTodayWidget"] mutableCopy] forKey:@"kIdentifiersArray"];

	widgetsArray = [widgetsArray mutableCopy];

	NSLog(@"[LockWidgets] (DEBUG) Current Enabled State: %i", kEnabled);
	NSLog(@"[LockWidgets] (DEBUG) Current Identifiers: %@", widgetsArray);
}

%ctor {
	reloadPrefs();

	if(@available(iOS 13.0, *)) {
		NSLog(@"[LockWidgets] (INFO) Current version is iOS 13!");
		%init(ios13)
	} else {
		NSLog(@"[LockWidgets] (INFO) Current version is iOS 12 or lower!");
		%init(old)
	}

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, CFSTR("me.conorthedev.lockwidgets.prefs/ReloadPrefs"), NULL, kNilOptions);
}
