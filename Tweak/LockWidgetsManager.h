#import "../Common.h"

@interface LockWidgetsManager : NSObject
- (NSArray *)allWidgetIdentifiers:(WGWidgetDiscoveryController *)wdc;
- (NSArray *)allExtensionFilePaths;
- (NSArray *)allExtensionIdentifiers;
- (NSDictionary *)extensionInfoFromIdentifier:(NSString *)identifier;
@end
