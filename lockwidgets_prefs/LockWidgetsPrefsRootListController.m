#include "LockWidgetsPrefsRootListController.h"
#include "NSTask.h"

@implementation LockWidgetsPrefsRootListController
@synthesize respringButton;

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:75.0/255.0 green:194.0/255.0 blue:237.0/255.0 alpha:1.0];
}

-(void)loadView {
    [super loadView];
}

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

- (void)respring {
	NSTask *t = [[NSTask alloc] init];
	[t setLaunchPath:@"/usr/bin/killall"];
	[t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
	[t launch];
}

@end
