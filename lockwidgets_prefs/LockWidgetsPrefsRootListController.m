#include "LockWidgetsPrefsRootListController.h"
#include "NSTask.h"

#define THEME_COLOR [UIColor colorWithRed:75.0 / 255.0 green:194.0 / 255.0 blue:237.0 / 255.0 alpha:1.0];

@implementation LockWidgetsPrefsRootListController
@synthesize respringButton;

+ (UIColor *)hb_tintColor
{
	return THEME_COLOR;
}

- (void)loadView
{
	[super loadView];
}

+ (NSString *)hb_specifierPlist
{
	return @"Root";
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationController.navigationController.navigationBar.barTintColor = THEME_COLOR;
	self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationController.navigationBar.barTintColor = THEME_COLOR;
	self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationController.navigationBar.translucent = NO;
}

- (void)respring
{
	NSTask *t = [[NSTask alloc] init];
	[t setLaunchPath:@"/usr/bin/killall"];
	[t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
	[t launch];
}

@end
