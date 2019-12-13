#import "../Common.h"

@interface LockWidgetsManager : NSObject
//- (LWView *)getLWViewFromIdentifier:(NSString *)identifier;
- (NSArray *)allWidgetIdentifiers:(WGWidgetDiscoveryController *)wdc;
@end