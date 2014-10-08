#import <UIKit/UIKit.h>
#import "GRXLayoutParams.h"
#import "UIView+GRXLayout.h"

@interface GRXLayout : UIView

@property (nonatomic) UIEdgeInsets padding;
@property (nonatomic, getter = isHierarchyDirty) BOOL dirtyHierarchy;

// This property specifies if this layout must take into account the parent's size
// when it is going to be measured ONLY IF the parent is not an instance of GRXLayout
@property (nonatomic) BOOL ignoreNonLayoutParentSize; // YES by default

+ (Class)layoutParamsClass;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;

- (void)addSubview:(UIView *)view;
- (void)addSubview:(UIView *)view
      layoutParams:(GRXLayoutParams *)layoutParams;

- (void)addSubviews:(NSArray *)views;
- (void)addSubviews:(NSArray *)views
       layoutParams:(GRXLayoutParams *)layoutParams;

- (void)setHierarchyDirty;

@end
