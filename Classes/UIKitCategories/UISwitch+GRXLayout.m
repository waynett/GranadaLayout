#import "UISwitch+GRXLayout.h"
#import "UIDevice+Util.h"

@implementation UISwitch (GRXLayout)

- (CGSize) grx_suggestedMinimumSize {
    if([UIDevice grx_runningSystemVersion7]) {
        return CGSizeMake(51, 31);
    } else {
        return CGSizeMake(79, 27);
    }
}

// UISwitches always have the same size, and -sizeThatFits: returns the currentSize

- (CGSize)grx_measureWithSpec:(GRXMeasureSpec)spec {
    CGSize size = [self grx_suggestedMinimumSize];
    return size;
}

@end