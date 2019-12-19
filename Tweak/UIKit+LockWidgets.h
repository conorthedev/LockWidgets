#import <UIKit/UICollectionView.h>
#import <UIKit/UIDataSourceTranslating.h>
#import <UIKit/UIScrollView.h>

@implementation UICollectionView (LockWidgets)
- (void)setSizeToMimic:(CGSize)arg1 {
}
@end

@interface UIView (RemoveConstraints)

- (void)removeAllConstraints;

@end

@implementation UIView (RemoveConstraints)

- (void)removeAllConstraints {
	UIView *superview = self.superview;
	while (superview != nil) {
		for (NSLayoutConstraint *c in superview.constraints) {
			if (c.firstItem == self || c.secondItem == self) {
				[superview removeConstraint:c];
			}
		}
		superview = superview.superview;
	}

	[self removeConstraints:self.constraints];
	self.translatesAutoresizingMaskIntoConstraints = YES;
}

@end

@interface UIImage (Private)
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier roleIdentifier:(NSString *)roleIdentifier format:(int)format scale:(CGFloat)scale;
@end