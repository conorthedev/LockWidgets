#import <UIKit/UIKit.h>

@interface WGWidgetListItemViewController : UIViewController 
{
	NSString* _widgetIdentifier;
}

@property(nonatomic, copy, readonly) NSString *widgetIdentifier;

- (id)initWithWidgetIdentifier:(id)arg1;

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

	WGWidgetListItemViewController *widget = [[WGWidgetListItemViewController alloc] initWithWidgetIdentifier:@"com.apple.UpNextWidget.extension"];
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
	view.backgroundColor = [UIColor redColor];
	[self addChildViewController:widget];
	[view addSubview:widget.view];
	widget.view.frame = view.frame;
	widget.view.translatesAutoresizingMaskIntoConstraints = NO;
	[widget didMoveToParentViewController:self];
	[stackView addArangedSubview:view];

	/*self.widgetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	self.widgetView.backgroundColor = [UIColor redColor];

	[stackView addArrangedSubview:self.widgetView];
*/
	[NSLayoutConstraint activateConstraints:@[
            [widget.view.centerXAnchor constraintEqualToAnchor:stackView.centerXAnchor],
            [widget.view.leadingAnchor constraintEqualToAnchor:stackView.leadingAnchor constant:10],
            [widget.view.trailingAnchor constraintEqualToAnchor:stackView.trailingAnchor constant:-10],
            [widget.view.heightAnchor constraintEqualToConstant:90]
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