#import <Cephei/HBRespringController.h>
#import <CepheiPrefs/HBRootListController.h>
#import <Preferences/PSListController.h>

@interface LockWidgetsPrefsRootListController : HBRootListController
- (void)respring:(id)sender;

@property (nonatomic, retain) UIBarButtonItem *respringButton;

@end
