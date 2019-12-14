#import "LockWidgetsManager.h"

/*
The class that handles all of the generation
i.e. generating an array of identifiers, generating a widget view, etc.
*/

@implementation LockWidgetsManager

// Return an NSArray of the available widget identifiers that can be used
- (NSArray *)allWidgetIdentifiers:(WGWidgetDiscoveryController *)wdc {
	NSArray *widgetsArray = @[];
	widgetsArray = [widgetsArray arrayByAddingObjectsFromArray:wdc.disabledWidgetIdentifiers];
	widgetsArray = [widgetsArray arrayByAddingObjectsFromArray:wdc.enabledWidgetIdentifiersForAllGroups];

	return widgetsArray;
}
@end