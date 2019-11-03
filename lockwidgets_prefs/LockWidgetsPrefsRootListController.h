#import <Preferences/PSListController.h>
#import <CepheiPrefs/HBRootListController.h>

@interface LockWidgetsPrefsRootListController : HBRootListController
- (void)respring;

@property(nonatomic, retain) UIBarButtonItem *respringButton;

@end
