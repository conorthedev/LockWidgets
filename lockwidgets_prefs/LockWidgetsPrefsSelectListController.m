#include "LockWidgetsPrefsSelectListController.h"

@implementation LockWidgetsPrefsSelectListController

static CPDistributedMessagingCenter *c = nil;
static NSString *cellIdentifier = @"Cell";

- (void)viewDidLoad {
	[super viewDidLoad];
		c = [CPDistributedMessagingCenter centerNamed:@"me.conorthedev.lockwidgets.messagecenter"];

	// Send a message with no dictionary and receive a reply dictionary
	NSDictionary * reply = [c sendMessageAndReceiveReplyName:@"getWidgets" userInfo:nil];

	NSArray *keys = [reply allKeys];

	NSString* str = keys[0];
	NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"() "];
	NSArray *array = [[[str componentsSeparatedByCharactersInSet:characterSet]
                        componentsJoinedByString:@""]     
                        componentsSeparatedByString:@","];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row]; // 셀 타이틀 텍스트
    cell.detailTextLabel.text = [self.tableDetailData objectAtIndex:indexPath.row];; // 셀 디테일 텍스트
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Table row %ld has been tapped", indexPath.row);
    
    NSString *messageString = [NSString stringWithFormat:@"You tapped row %ld",indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row tapped"
                                                    message:messageString
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}


#pragma mark 행 높이

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


@end
