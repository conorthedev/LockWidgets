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

- (NSArray *)allExtensionIdentifiers {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *directory = @"/Library/Application Support/LockWidgets/Extensions/";
	NSArray *extensionPlists = [manager contentsOfDirectoryAtPath:directory error:nil];
	NSMutableArray *extensionInfos = [NSMutableArray new];

	for (NSString *filename in extensionPlists) {
		NSString *path = [directory stringByAppendingPathComponent:filename];
		NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];

		if (plist) {
			NSString *specifier = plist[@"specifier"];

			[extensionInfos addObject:specifier];
		}
	}

	return [NSArray arrayWithArray:extensionInfos];
}

- (NSString *)extensionIdentifierFromFilePath:(NSString *)path {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];

	if (plist) {
		NSString *specifier = plist[@"specifier"];

		return specifier;
	} else {
		return @"Unknown";
	}
}

- (NSString *)extensionFilePathFromIdentifier:(NSString *)identifier {
	NSArray *files = [self allExtensionFilePaths];

	for (NSString *filePath in files) {
		NSFileManager *manager = [NSFileManager defaultManager];
		NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:filePath];

		if (plist) {
			NSString *specifier = plist[@"specifier"];

			if ([specifier isEqualToString:identifier]) {
				return filePath;
			} else {
				continue;
			}
		}
	}
	return @"Unknown";
}

- (NSArray *)allExtensionFilePaths {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *directory = @"/Library/Application Support/LockWidgets/Extensions/";
	NSArray *extensionPlists = [manager contentsOfDirectoryAtPath:directory error:nil];
	NSMutableArray *extensionPaths = [NSMutableArray new];

	for (NSString *filename in extensionPlists) {
		NSString *path = [directory stringByAppendingPathComponent:filename];

		[extensionPaths addObject:path];
	}

	return [NSArray arrayWithArray:extensionPaths];
}

- (NSDictionary *)extensionInfoFromIdentifier:(NSString *)identifier {
	NSString *path = [self extensionFilePathFromIdentifier:identifier];
	NSString *directory = @"/Library/Application Support/LockWidgets/Extensions/";

	NSLog(@"[LockWidgets] (DEBUG) Path: %@", path);

	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];

	NSLog(@"[LockWidgets] (DEBUG) Plist: %@", plist);

	if (plist) {
		UIImage *image = [UIImage imageWithContentsOfFile:[directory stringByAppendingPathComponent:plist[@"iconPath"]]];
		NSLog(@"[LockWidgets] (DEBUG) Image Path: %@", [directory stringByAppendingPathComponent:plist[@"iconPath"]]);
		NSLog(@"[LockWidgets] (DEBUG) Image: %@", image);

		return @{
			@"displayName" : plist[@"displayName"],
			@"imageData" : UIImagePNGRepresentation(image),
			@"mainClass" : plist[@"mainClass"],
			@"specifier" : plist[@"specifier"]
		};
	} else {
		return nil;
	}
}

@end