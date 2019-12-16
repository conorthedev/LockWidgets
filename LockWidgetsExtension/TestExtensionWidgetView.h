#import <UIKit/UIKit.h>

@interface TestExtensionWidgetView : NSObject
- (void)viewWillDisplay;
- (UIView *)extensionViewFromFrame:(CGRect)frame;
@end