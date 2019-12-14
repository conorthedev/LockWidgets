#include "LockWidgetsPrefsRootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>

#define THEME_COLOR [UIColor colorWithRed:75.0 / 255.0 green:194.0 / 255.0 blue:237.0 / 255.0 alpha:1.0];

@implementation LockWidgetsPrefsRootListController
@synthesize respringButton;

- (instancetype)init
{
	self = [super init];

	if (self)
	{
		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(respring:)];
		self.respringButton.tintColor = [UIColor redColor];
		self.navigationItem.rightBarButtonItem = self.respringButton;
	}

	return self;
}

+ (UIColor *)hb_tintColor
{
	return THEME_COLOR;
}

- (void)loadView
{
	[super loadView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (@available(iOS 11, *))
	{
		self.navigationController.navigationBar.prefersLargeTitles = false;
		self.navigationController.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
	}
}

+ (NSString *)hb_specifierPlist
{
	return @"Root";
}

- (void)respring:(id)sender
{
	[HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=LockWidgets"]];
}

@end
