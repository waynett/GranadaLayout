#import "GRXComplexHeaderView.h"
#import <GranadaLayout/UIView+GRXLayoutInflater.h>

@interface GRXComplexHeaderView ()

@property (nonatomic) UIImageView *image;
@property (nonatomic) UITextView *title, *message;
@property (nonatomic) UILabel *subtitle;

@end

@implementation GRXComplexHeaderView

- (void)grx_didLoadFromInflater:(GRXLayoutInflater *)inflater {
    self.image = (UIImageView*) [inflater.rootView grx_findViewWithIdentifier:@"image"];
    self.image.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.image.layer.borderWidth = 1;
    self.image.contentMode = UIViewContentModeScaleAspectFit;

    self.title = (UITextView *) [inflater.rootView grx_findViewWithIdentifier:@"title"];
    self.title.font = [UIFont boldSystemFontOfSize:16];

    self.subtitle = (UILabel *) [inflater.rootView grx_findViewWithIdentifier:@"subtitle"];
    self.subtitle.numberOfLines = 1000;
    self.subtitle.font = [UIFont systemFontOfSize:12];
    self.subtitle.textColor = [UIColor grayColor];

    self.message = (UITextView *) [inflater.rootView grx_findViewWithIdentifier:@"message"];
    self.message.font = [UIFont systemFontOfSize:14];
}

- (void)setHeader:(GRXComplexDataHeader *)header {
    self.image.image = header.image;
    self.image.grx_visibility = header.image != nil ? GRXVisibilityVisible : GRXVisibilityGone;

    self.title.text = header.title; // we always will have a title

    self.subtitle.text = header.formattedDate;  // we will always have a subtitle

    self.message.text = header.message;
    self.message.grx_visibility = header.message.length > 0 ? GRXVisibilityVisible : GRXVisibilityGone;
}

@end
