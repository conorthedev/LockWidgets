#import <UIKit/UIKit.h>

@interface LockWidgetsExtension : NSObject
- (void)viewWillDisplay;
- (UIView *)extensionViewFromFrame:(CGRect)frame;
@end