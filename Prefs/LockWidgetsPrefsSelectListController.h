#import <Preferences/PSViewController.h>
#import <objc/runtime.h>
#import "../Common.h"

@interface LockWidgetsPrefsSelectListController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *_tableView;
}
@property (nonatomic, strong) NSArray *tableData;			   // holds the table data (title)
@property (nonatomic, strong) NSArray *extensionIdentifiers;   // holds the data for the extensions
@property (nonatomic, strong) NSMutableArray *tableDetailData; // holds the table data (detail text)
@property (strong, nonatomic) UITableView *tableView;

- (void)refreshList;
@end