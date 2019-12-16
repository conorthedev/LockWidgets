#import <UIKit/UIKit.h>

@interface LockWidgetsExtension : NSObject
-(BOOL)init;
-(UIView *)extensionViewForSize:(CGSize*)size;
@end