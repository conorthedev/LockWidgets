#include "LockWidgetsPrefsSelectListController.h"

@implementation LockWidgetsPrefsSelectListController

CPDistributedMessagingCenter *c = nil;
NSString *cellIdentifier = @"Cell";

NSMutableArray *currentWidgetIdentifiers = nil;
NSMutableArray *currentExtensionIdentifiers = nil;

NSArray *availableWidgetsCache = nil;
NSArray *availableExtensionsCache = nil;

NSMutableDictionary *widgetCellInfoCache = nil;
BOOL refreshDictionary = YES;

- (id)initForContentSize:(CGSize)size {
	self = [super init];

	if (self) {
		[self refreshList];

		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:NO];
		[_tableView setAllowsSelection:YES];
		[_tableView setAllowsMultipleSelection:NO];
		self.tableView = _tableView;

		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self refreshList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = @"Select Active Widgets";
	[self refreshList];
}

- (NSString *)navigationTitle {
	return @"Select Active Widgets";
}

- (void)refreshList {
	[self.tableView reloadData];
	c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];
	NSDictionary *reply = [c sendMessageAndReceiveReplyName:@"getWidgets" userInfo:nil];

	// Get a list of available widget identifiers
	if (availableWidgetsCache == nil) {
		if (self.tableData == nil) {
			NSArray *widgets = reply[@"widgets"];
			availableWidgetsCache = widgets;
			self.tableData = availableWidgetsCache;
		}
	} else {
		if (availableExtensionsCache == nil) {
			NSLog(@"[LockWidgetsPrefs] (DEBUG) availableExtensionsCache is nil!");
			if (self.extensionIdentifiers == nil) {
				NSLog(@"[LockWidgetsPrefs] (DEBUG) self.extensionIdentifiers is nil!");
				NSArray *extensions = reply[@"extensions"];
				availableExtensionsCache = extensions;
				self.extensionIdentifiers = availableExtensionsCache;
				NSLog(@"[LockWidgetsPrefs] (DEBUG) self.extensionIdentifiers is now: %@!", self.extensionIdentifiers);
			}
		} else {
			if (self.tableData == nil) {
				self.tableData = availableWidgetsCache;
			}

			if (self.extensionIdentifiers == nil) {
				self.extensionIdentifiers = availableExtensionsCache;
			}
		}
	}

	// Get the list of currently active identifiers
	NSDictionary *identifierReply = [c sendMessageAndReceiveReplyName:@"getCurrentIdentifiers" userInfo:nil];

	NSMutableArray *currentIdentifiers = identifierReply[@"currentIdentifiers"];
	currentWidgetIdentifiers = currentIdentifiers;

	for (int section = 0, sectionCount = self.tableView.numberOfSections; section < sectionCount; ++section) {
		for (int row = 0, rowCount = [self.tableView numberOfRowsInSection:section]; row < rowCount; ++row) {
			[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];

			for (NSString *identifier in currentWidgetIdentifiers) {
				if ([cell.detailTextLabel.text isEqualToString:identifier]) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
					return;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
			}
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [self.extensionIdentifiers count];
	} else {
		return [self.tableData count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}

	NSLog(@"[LockWidgetsPrefs] (DEBUG): Current Section: %ld | Current Row: %ld", indexPath.section, indexPath.row);

	if (indexPath.section == 0) {
		NSString *identifier = [self.extensionIdentifiers objectAtIndex:indexPath.row];

		c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];
		NSDictionary *reply = [c sendMessageAndReceiveReplyName:@"getExtensionInfo" userInfo:@{@"identifier" : identifier}];

		NSLog(@"[LockWidgetsPrefs] (DEBUG): Data from %@: %@", identifier, reply);

		NSData *imageData = reply[@"imageData"];
		UIImage *image = [UIImage imageWithData:imageData];

		cell.textLabel.text = reply[@"displayName"];
		cell.detailTextLabel.text = identifier;
		cell.detailTextLabel.textColor = [UIColor grayColor];

		if (image) {
			UIGraphicsBeginImageContext(CGSizeMake(30, 30));

			[image drawInRect:CGRectMake(0, 0, 30, 30)];

			UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();

			UIGraphicsEndImageContext();
			if (newThumbnail == nil) {
				NSLog(@"could not scale image");
				cell.imageView.image = image;
			} else {
				cell.imageView.image = newThumbnail;
			}
		} else {
			cell.imageView.image = nil;
		}

		for (NSString *identifier in currentWidgetIdentifiers) {
			if ([cell.detailTextLabel.text isEqualToString:identifier]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
	} else {
		if (widgetCellInfoCache == nil) {
			widgetCellInfoCache = [[NSMutableDictionary alloc] init];
		}

		NSString *identifier = [self.tableData objectAtIndex:indexPath.row];

		NSDictionary *reply = [widgetCellInfoCache objectForKey:identifier];

		if (refreshDictionary || reply == nil) {
			c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];
			reply = [c sendMessageAndReceiveReplyName:@"getInfo" userInfo:@{@"identifier" : identifier}];

			[widgetCellInfoCache setObject:reply forKey:identifier];

			refreshDictionary = NO;
		}

		NSData *imageData = reply[@"imageData"];
		UIImage *image = [UIImage imageWithData:imageData];

		cell.textLabel.text = reply[@"displayName"];
		cell.detailTextLabel.text = identifier;
		cell.detailTextLabel.textColor = [UIColor grayColor];

		if (image) {
			UIGraphicsBeginImageContext(CGSizeMake(30, 30));

			[image drawInRect:CGRectMake(0, 0, 30, 30)];

			UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();

			UIGraphicsEndImageContext();
			if (newThumbnail == nil) {
				NSLog(@"could not scale image");
				cell.imageView.image = image;
			} else {
				cell.imageView.image = newThumbnail;
			}
		} else {
			cell.imageView.image = nil;
		}

		for (NSString *identifier in currentWidgetIdentifiers) {
			if ([cell.detailTextLabel.text isEqualToString:identifier]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				return cell;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier;
	bool isExtension;

	if (indexPath.section == 0) {
		isExtension = YES;
		identifier = [self.extensionIdentifiers objectAtIndex:indexPath.row];
	} else {
		isExtension = NO;
		identifier = [self.tableData objectAtIndex:indexPath.row];
	}

	c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];

	NSDictionary *reply = [c sendMessageAndReceiveReplyName:@"setIdentifier" userInfo:@{@"identifier" : identifier, @"isExtension" : @(isExtension)}];

	NSDictionary *displayReply = [widgetCellInfoCache objectForKey:identifier];

	if (!(bool)reply[@"status"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
														message:[NSString stringWithFormat:@"Failed to toggle widget \"%@\"!", displayReply[@"displayName"]]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];

		[alert show];
	}

	refreshDictionary = YES;

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	[self refreshList];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *sectionName;
	switch (section) {
		case 0:
			sectionName = @"Available Extensions";
			break;
		case 1:
			sectionName = @"Available Widgets";
			break;
		default:
			sectionName = @"";
			break;
	}
	return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

@end
