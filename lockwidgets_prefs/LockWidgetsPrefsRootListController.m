#include "LockWidgetsPrefsRootListController.h"
#include "NSTask.h"

@implementation LockWidgetsPrefsRootListController
@synthesize respringButton;

- (instancetype)init {
	self = [super init];

	if (self) {
		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
		                       style:UIBarButtonItemStylePlain
		                       target:self
		                       action:@selector(respring)];
		self.respringButton.tintColor = [UIColor redColor];
		self.navigationItem.rightBarButtonItem = self.respringButton;
	}

	return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)respring {
	NSTask *t = [[NSTask alloc] init];
	[t setLaunchPath:@"/usr/bin/killall"];
	[t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
	[t launch];
}

@end
