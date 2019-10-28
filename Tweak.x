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
    NSExtension *extension = [NSExtension extensionWithIdentifier:@"com.apple.UpNextWidget.extension" error:&error];
    WGWidgetInfo *widgetInfo = [[%c(WGWidgetInfo) alloc] initWithExtension:extension];
    
	WGWidgetListItemViewController *widget = [[%c(WGWidgetListItemViewController) alloc] initWithWidgetIdentifier:@"com.apple.UpNextWidget.extension"];
    WGWidgetHostingViewController *widgetHost = [[%c(WGWidgetHostingViewController) alloc] initWithWidgetInfo:widgetInfo delegate:self host:widget];
    
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
