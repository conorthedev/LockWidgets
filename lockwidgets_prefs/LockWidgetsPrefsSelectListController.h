#import <Preferences/PSViewController.h>
#import <objc/runtime.h>
#import "../Common.h"

@interface LockWidgetsPrefsSelectListController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSArray *tableData; // holds the table data (title)
@property (nonatomic, strong) NSMutableArray *tableDetailData; // holds the table data (detail text)

- (void)refreshList;
@end