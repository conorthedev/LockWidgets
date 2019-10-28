#import <UIKit/UIKit.h>

@interface NSExtension : NSObject

+ (instancetype)extensionWithIdentifier:(NSString *)identifier error:(NSError **)error;

- (void)beginExtensionRequestWithInputItems:(NSArray *)inputItems completion:(void (^)(NSUUID *requestIdentifier))completion;

- (int)pidForRequestIdentifier:(NSUUID *)requestIdentifier;
- (void)cancelExtensionRequestWithIdentifier:(NSUUID *)requestIdentifier;

- (void)setRequestCancellationBlock:(void (^)(NSUUID *uuid, NSError *error))cancellationBlock;
- (void)setRequestCompletionBlock:(void (^)(NSUUID *uuid, NSArray *extensionItems))completionBlock;
- (void)setRequestInterruptionBlock:(void (^)(NSUUID *uuid))interruptionBlock;

@end

@interface WGWidgetInfo : NSObject {

	NSPointerArray* _registeredWidgetHosts;
	struct {
		unsigned didInitializeWantsVisibleFrame : 1;
	}  _widgetInfoFlags;
	BOOL _wantsVisibleFrame;
	NSString* _sdkVersion;
	NSExtension* _extension;
	long long _initialDisplayMode;
	long long _largestAllowedDisplayMode;
	NSString* _displayName;
	CGSize _preferredContentSize;
}
@property (assign,nonatomic) CGSize preferredContentSize;                                                            //@synthesize preferredContentSize=_preferredContentSize - In the implementation block
@property (setter=_setDisplayName:,nonatomic,copy) NSString * displayName;                                           //@synthesize displayName=_displayName - In the implementation block
@property (getter=_sdkVersion,nonatomic,copy,readonly) NSString * sdkVersion;                                        //@synthesize sdkVersion=_sdkVersion - In the implementation block
@property (assign,setter=_setLargestAllowedDisplayMode:,nonatomic) long long largestAllowedDisplayMode;              //@synthesize largestAllowedDisplayMode=_largestAllowedDisplayMode - In the implementation block
@property (assign,setter=_setWantsVisibleFrame:,nonatomic) BOOL wantsVisibleFrame;                                   //@synthesize wantsVisibleFrame=_wantsVisibleFrame - In the implementation block
@property (nonatomic,readonly) NSExtension * extension;                                                              //@synthesize extension=_extension - In the implementation block
@property (nonatomic,copy,readonly) NSString * widgetIdentifier; 
@property (nonatomic,readonly) double initialHeight; 
@property (nonatomic,readonly) long long initialDisplayMode;                                                         //@synthesize initialDisplayMode=_initialDisplayMode - In the implementation block
+(id)_productVersion;
+(double)maximumContentHeightForCompactDisplayMode;
+(id)widgetInfoWithExtension:(id)arg1 ;
+(void)_updateRowHeightForContentSizeCategory;
-(id)_icon;
-(NSString *)widgetIdentifier;
-(id)_queue_iconWithFormat:(int)arg1 forWidgetWithIdentifier:(id)arg2 extension:(id)arg3 ;
-(int)_outlineVariantForScale:(double)arg1 ;
-(id)_queue_iconWithOutlineForWidgetWithIdentifier:(id)arg1 extension:(id)arg2 ;
-(void)_resetIconsImpl;
-(void)_resetIcons;
-(id)widgetInfoWithExtension:(id)arg1 ;
-(void)_setLargestAllowedDisplayMode:(long long)arg1 ;
-(BOOL)isLinkedOnOrAfterSystemVersion:(id)arg1 ;
-(void)requestSettingsIconWithHandler:(/*^block*/id)arg1 ;
-(void)requestIconWithHandler:(/*^block*/id)arg1 ;
-(id)_queue_iconFromWidgetBundleForWidgetWithIdentifier:(id)arg1 extension:(id)arg2 ;
-(void)_requestIcon:(BOOL)arg1 withHandler:(/*^block*/id)arg2 ;
-(id)_sdkVersion;
-(double)initialHeight;
-(BOOL)wantsVisibleFrame;
-(void)_setWantsVisibleFrame:(BOOL)arg1 ;
-(void)registerWidgetHost:(id)arg1 ;
-(void)updatePreferredContentSize:(CGSize)arg1 forWidgetHost:(id)arg2 ;
-(long long)initialDisplayMode;
-(long long)largestAllowedDisplayMode;
-(id)initWithExtension:(id)arg1 ;
-(CGSize)preferredContentSize;
-(void)setPreferredContentSize:(CGSize)arg1 ;
-(NSExtension *)extension;
@end

@interface WGWidgetHostingViewController : UIViewController {
    	WGWidgetInfo* _widgetInfo;
}
- (id)initWithWidgetInfo:(id)arg1 delegate:(id)arg2 host:(id)arg3;
- (WGWidgetInfo *)widgetInfo;
@end


@interface WGWidgetListItemViewController : UIViewController 
{
	NSString* _widgetIdentifier;
    WGWidgetHostingViewController* _widgetHost;
}

@property(nonatomic, copy, readonly) NSString *widgetIdentifier;
@property (nonatomic,readonly) WGWidgetHostingViewController* widgetHost;

- (id)initWithWidgetIdentifier:(id)arg1;
- (id)widgetHost;

@end

@protocol WGWidgetListItemViewControllerDelegate <NSObject>
- (WGWidgetHostingViewController *)widgetListItemViewController:(WGWidgetListItemViewController *)arg1 widgetHostWithIdentifier:(NSString *)arg2;
@end

@interface SBDashBoardNotificationAdjunctListViewController : UIViewController <WGWidgetListItemViewControllerDelegate>
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

@interface PLPlatterHeaderContentView : UIView {

	UILabel* _dateLabel;
	NSArray* _iconButtons;
	UIImageView* _iconButtonShadow;
	UIButton* _utilityButton;
	BOOL _hasUpdatedContent;
	BOOL _adjustsFontForContentSizeCategory;
	BOOL _dateAllDay;
	BOOL _heedsHorizontalLayoutMargins;
	BOOL _usesLargeTextLayout;
	NSString* _preferredContentSizeCategory;
	NSDate* _date;
	NSTimeZone* _timeZone;
	long long _dateFormatStyle;
	UIView* _utilityView;
	UILabel* _titleLabel;
	double _utilityButtonHorizontalLayoutReference;
}
@property (getter=_titleLabel,nonatomic,readonly) UILabel * titleLabel; 
@property (getter=_dateLabel,nonatomic,readonly) UILabel * dateLabel; 
@property (getter=_titleLabelFont,nonatomic,readonly) UIFont * titleLabelFont; 
@property (getter=_dateLabelFont,nonatomic,readonly) UIFont * dateLabelFont; 
@property (assign,setter=_setUsesLargeTextLayout:,getter=_usesLargeTextLayout,nonatomic) BOOL usesLargeTextLayout; 
@property (assign,setter=_setUtilityButtonHorizontalLayoutReference:,getter=_utilityButtonHorizontalLayoutReference,nonatomic) double utilityButtonHorizontalLayoutReference; 
@property (getter=_iconDimension,nonatomic,readonly) double iconDimension; 
@property (getter=_iconLeadingPadding,nonatomic,readonly) double iconLeadingPadding; 
@property (getter=_iconTrailingPadding,nonatomic,readonly) double iconTrailingPadding;                                                //@synthesize utilityButtonHorizontalLayoutReference=_utilityButtonHorizontalLayoutReference - In the implementation block
@property (nonatomic,copy) NSArray * icons; 
@property (nonatomic,copy) NSString * title; 
@property (nonatomic,copy) NSDate * date;                                                                                                                                                  //@synthesize date=_date - In the implementation block
@property (assign,getter=isDateAllDay,nonatomic) BOOL dateAllDay;                                                                                                                          //@synthesize dateAllDay=_dateAllDay - In the implementation block
@property (nonatomic,copy) NSTimeZone * timeZone;                                                                                                                                          //@synthesize timeZone=_timeZone - In the implementation block
@property (assign,nonatomic) long long dateFormatStyle;                                                                                                                                    //@synthesize dateFormatStyle=_dateFormatStyle - In the implementation block
@property (nonatomic,readonly) NSArray * iconButtons;                                                                                                                                      //@synthesize iconButtons=_iconButtons - In the implementation block
@property (nonatomic,readonly) UIButton * utilityButton; 
@property (nonatomic,retain) UIView * utilityView;                                                                                                                                         //@synthesize utilityView=_utilityView - In the implementation block
@property (assign,nonatomic) BOOL heedsHorizontalLayoutMargins;                                                                                                                            //@synthesize heedsHorizontalLayoutMargins=_heedsHorizontalLayoutMargins - In the implementation block
@property (nonatomic,readonly) double contentBaseline; 
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy,readonly) NSString * description; 
@property (copy,readonly) NSString * debugDescription;                                                                                                         //@synthesize vibrantStylingProvider=_vibrantStylingProvider - In the implementation block
@property (assign,nonatomic) BOOL adjustsFontForContentSizeCategory;                                                                                                                       //@synthesize adjustsFontForContentSizeCategory=_adjustsFontForContentSizeCategory - In the implementation block
@property (nonatomic,copy) NSString * preferredContentSizeCategory;                                                                                                                        //@synthesize preferredContentSizeCategory=_preferredContentSizeCategory - In the implementation block
-(void)_setTitleLabel:(id)arg1 ;
-(id)_titleLabelFont;
-(void)setUtilityView:(UIView *)arg1 ;
-(id)_dateLabelFont;
-(BOOL)isDateAllDay;
-(void)setDateAllDay:(BOOL)arg1 ;
-(void)setDateFormatStyle:(long long)arg1 ;
-(BOOL)adjustForContentSizeCategoryChange;
-(long long)dateFormatStyle;
-(NSArray *)iconButtons;
-(UIButton *)utilityButton;
-(id)_fontProvider;
-(void)_setFontProvider:(id)arg1 ;
-(void)_darkerSystemColorsStatusDidChange:(id)arg1 ;
-(void)_reduceTransparencyStatusDidChange:(id)arg1 ;
-(void)vibrantStylingDidChangeForProvider:(id)arg1 ;
-(id)_dateLabel;
-(id)_utilityButton;
-(BOOL)heedsHorizontalLayoutMargins;
-(UIView *)utilityView;
-(double)contentBaseline;
-(void)_setUtilityButtonHorizontalLayoutReference:(double)arg1 ;
-(void)_recycleDateLabel;
-(BOOL)_usesLargeTextLayout;
-(double)_headerHeightForWidth:(double)arg1 ;
-(void)_configureIconButtonsForIcons:(id)arg1 ;
-(void)_updateTextAttributesForTitleLabel:(id)arg1 ;
-(id)_titleLabelPreferredFont;
-(id)_updateTitleAttributesForAttributedString:(id)arg1 ;
-(void)_configureTitleLabel:(id)arg1 ;
-(id)_lazyTitleLabel;
-(id)_attributedStringForTitle:(id)arg1 ;
-(double)_iconDimension;
-(double)_iconLeadingPadding;
-(double)_iconTrailingPadding;
-(id)_dateLabelPreferredFont;
-(void)_configureDateLabel;
-(void)_tearDownDateLabel;
-(void)_configureUtilityButtonIfNecessary;
-(void)_configureDateLabelIfNecessary;
-(void)_layoutIconButtonsWithScale:(double)arg1 ;
-(void)_layoutUtilityButtonWithScale:(double)arg1 ;
-(void)_layoutDateLabelWithScale:(double)arg1 ;
-(void)_layoutTitleLabelWithScale:(double)arg1 ;
-(void)_updateStylingForTitleLabel:(id)arg1 ;
-(void)_updateUtilityButtonVibrantStyling;
-(void)_setUsesLargeTextLayout:(BOOL)arg1 ;
-(void)_updateTextAttributesForDateLabel;
-(void)_updateUtilityButtonFont;
-(void)dateLabelDidChange:(id)arg1 ;
-(void)setHeedsHorizontalLayoutMargins:(BOOL)arg1 ;
-(double)_utilityButtonHorizontalLayoutReference;
-(void)_configureUtilityButton;
-(id)init;
-(void)dealloc;
-(NSString *)preferredContentSizeCategory;
-(void)setTitle:(NSString *)arg1 ;
-(NSString *)title;
-(void)layoutSubviews;
-(CGSize)sizeThatFits:(CGSize)arg1 ;
-(id)_titleLabel;
-(void)traitCollectionDidChange:(id)arg1 ;
-(void)layoutMarginsDidChange;
-(NSDate *)date;
-(id)_newTitleLabel;
-(id)_layoutManager;
-(BOOL)adjustsFontForContentSizeCategory;
-(NSArray *)icons;
-(NSTimeZone *)timeZone;
-(void)setTimeZone:(NSTimeZone *)arg1 ;
-(void)setDate:(NSDate *)arg1 ;
-(void)setPreferredContentSizeCategory:(NSString *)arg1 ;
-(void)setAdjustsFontForContentSizeCategory:(BOOL)arg1 ;
-(void)setIcons:(NSArray *)arg1 ;
@end