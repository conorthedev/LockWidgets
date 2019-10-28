#import "Tweak.h"

%hook SBDashBoardNotificationAdjunctListViewController
%property (nonatomic, retain) UIView *widgetView;

-(BOOL)hasContent {
    return YES;
}

-(void)viewDidLoad {
    %orig;
	UIStackView *stackView = [self valueForKey:@"_stackView"];

    NSError *error;
    NSExtension *extension = [NSExtension extensionWithIdentifier:@"com.apple.BatteryCenter.BatteryWidget" error:&error];
    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];
    
	WGWidgetListItemViewController *widget = [[%c(WGWidgetListItemViewController) alloc] initWithWidgetIdentifier:@"com.apple.UpNextWidget.extension"];
    WGWidgetHostingViewController *widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:nil host:widget];
    [widget setValue:widgetHost forKey:@"_widgetHost"];
    [widget.view setValue:widgetHost forKey:@"_widgetHost"];
    [widget setValue:self forKey:@"_delegate"];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    [view addSubview:widget.view];
    widget.view.frame = view.frame;
	widget.view.translatesAutoresizingMaskIntoConstraints = NO;
	[widget didMoveToParentViewController:self];

    [self addChildViewController:widgetHost];
	[view addSubview:widgetHost.view];
	widgetHost.view.frame = view.frame;
	widgetHost.view.translatesAutoresizingMaskIntoConstraints = NO;
	[widgetHost didMoveToParentViewController:self];
	[stackView addArrangedSubview:view];

    for (UIView *leView in widget.view.subviews) {
        for (PLPlatterHeaderContentView *header in leView.subviews) {
            if ([header isKindOfClass:[%c(PLPlatterHeaderContentView) class]]) {
                header.title = [widgetInfo.displayName uppercaseString];
            }
        }
    }
    
	[NSLayoutConstraint activateConstraints:@[
            [widgetHost.view.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [widgetHost.view.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [widgetHost.view.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [widgetHost.view.heightAnchor constraintEqualToConstant:150],
            [widgetHost.view.topAnchor constraintEqualToAnchor:stackView.topAnchor constant:40]
    ]];
        
	[NSLayoutConstraint activateConstraints:@[
            [widget.view.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [widget.view.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [widget.view.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [widget.view.heightAnchor constraintEqualToConstant:150]
    ]];
        
	[NSLayoutConstraint activateConstraints:@[
            [view.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [view.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [view.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [view.heightAnchor constraintEqualToConstant:150]
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
