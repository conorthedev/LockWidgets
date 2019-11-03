#import <CepheiPrefs/HBRootListController.h>
#import <Preferences/PSListController.h>

@interface LockWidgetsPrefsRootListController : HBRootListController
- (void)respring;

@property (nonatomic, retain) UIBarButtonItem *respringButton;

@end
