#include "LockWidgetsPrefsSelectListController.h"

@implementation LockWidgetsPrefsSelectListController

static CPDistributedMessagingCenter *c = nil;
static NSString *cellIdentifier = @"Cell";
static NSString *widgetIdentifier = nil;

- (id)initForContentSize:(CGSize)size
{
	self = [super init];

	if (self)
	{
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

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self refreshList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationItem.title = @"Select a Widget";
	[self refreshList];
}

- (NSString *)navigationTitle
{
	return @"Select a Widget";
}

- (void)refreshList
{
	[self.tableView reloadData];
	c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];

	// Get a list of available widget identifiers
	NSDictionary *reply = [c sendMessageAndReceiveReplyName:@"getWidgets" userInfo:nil];

	NSArray *widgets = reply[@"widgets"];
	self.tableData = widgets;

	// Get the current set identifier
	NSDictionary *identifierReply = [c sendMessageAndReceiveReplyName:@"getCurrentIdentifier" userInfo:nil];

	NSString *currentIdentifier = identifierReply[@"currentIdentifier"];
	widgetIdentifier = currentIdentifier;

	//NSLog(@"[LockWidgets] [PREFERENCES] (DEBUG) Current Identifier: %@", currentIdentifier);

	for (int section = 0, sectionCount = self.tableView.numberOfSections; section < sectionCount; ++section)
	{
		for (int row = 0, rowCount = [self.tableView numberOfRowsInSection:section]; row < rowCount; ++row)
		{
			[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];

			//NSLog(@"[LockWidgets] [PREFERENCES] (DEBUG) Current CELL Identifier: %@ | Equal?: %d", cell.detailTextLabel.text, [cell.detailTextLabel.text isEqualToString:currentIdentifier]);

			if ([cell.detailTextLabel.text isEqualToString:currentIdentifier])
			{
				[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForCell:cell]].accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else
			{
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}

	NSString *identifier = [self.tableData objectAtIndex:indexPath.row];

	c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];
	NSDictionary *reply = [c sendMessageAndReceiveReplyName:@"getInfo" userInfo:@{@"identifier" : identifier}];

	cell.textLabel.text = reply[@"displayName"];
	cell.detailTextLabel.text = identifier;
	cell.detailTextLabel.textColor = [UIColor grayColor];

	if ([cell.detailTextLabel.text isEqualToString:widgetIdentifier])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [self.tableData objectAtIndex:indexPath.row];

	c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];
	NSDictionary *reply = [c sendMessageAndReceiveReplyName:@"setIdentifier" userInfo:@{@"identifier" : identifier}];

	NSDictionary *displayReply = [c sendMessageAndReceiveReplyName:@"getInfo" userInfo:@{@"identifier" : identifier}];

	if ((bool)reply[@"status"])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
														message:[NSString stringWithFormat:@"Successfully set widget to %@", displayReply[@"displayName"]]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];

		[alert show];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
														message:[NSString stringWithFormat:@"Failed to set widget to %@!", displayReply[@"displayName"]]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];

		[alert show];
	}

	[self refreshList];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionName;
	switch (section)
	{
		case 0:
			sectionName = @"Available Widgets";
			break;
		default:
			sectionName = @"";
			break;
	}
	return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

@end
