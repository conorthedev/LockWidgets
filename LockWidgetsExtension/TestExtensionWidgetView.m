#import "TestExtensionWidgetView.h"

@implementation TestExtensionWidgetView
- (void)viewWillDisplay {
  NSLog(@"[LockWidgetsExtension] (DEBUG): real gang shit");
}

- (UIView *)extensionViewFromFrame:(CGRect)frame {
  UIView *view = [[UIView alloc] initWithFrame:frame];

  UILabel *helloLabel = [[UILabel alloc] init];
  [helloLabel setFrame:frame];
  helloLabel.backgroundColor = [UIColor clearColor];
  helloLabel.textColor = [UIColor blackColor];
  helloLabel.userInteractionEnabled = NO;
  helloLabel.text = @"Hello World";
  [view addSubview:helloLabel];

  return view;
}
@end