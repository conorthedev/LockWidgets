@interface SBDashBoardNotificationAdjunctListViewController : UIViewController
{
    UIStackView *_stackView;
}

@property(nonatomic, retain) UIView *widgetView;

- (void)adjunctListModel:(id)arg1 didAddItem:(id)arg2;
- (void)adjunctListModel:(id)arg1 didRemoveItem:(id)arg2;
- (void)_didUpdateDisplay;
- (CGSize)sizeToMimic;
- (void)_insertItem:(id)arg1 animated:(BOOL)arg2;
- (void)_removeItem:(id)arg1 animated:(BOOL)arg2;
- (BOOL)isPresentingContent;

@end