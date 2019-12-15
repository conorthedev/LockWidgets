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

- (NSArray *)allExtensionInfos {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *directory = @"/Library/Application Support/LockWidgets/Extensions/";
	NSArray *extensionPlists = [manager contentsOfDirectoryAtPath:directory error:nil];
	NSMutableArray *extensionInfos = [NSMutableArray new];

	for (NSString *filename in extensionPlists) {
		NSString *path = [directory stringByAppendingPathComponent:filename];
		NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];

		if (plist) {
			NSString *name = plist[@"name"] ?: [filename stringByReplacingOccurrencesOfString:@".plist" withString:@""];
			NSString *title = plist[@"title"] ?: name;

			NSString *specifier = plist[@"specifier"];
			NSString *mainClass = plist[@"mainClass"];

			[extensionInfos addObject:@{@"specifier" : specifier, @"mainClass" : mainClass}];
		}
	}

	return [NSArray arrayWithArray:extensionInfos];
}

@end