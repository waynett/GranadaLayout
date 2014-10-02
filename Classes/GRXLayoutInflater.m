#import "GRXLayoutInflater.h"
#import "GRXLinearLayout.h"
#import "GRXRelativeLayout.h"
#import "GRXLayout+GRXLayoutInflater.h"
#import "GRXRelativeLayout+GRXLayoutInflater.h"

@interface GRXLayoutInflater ()

@property (nonatomic, readonly) NSMutableDictionary * allViewsById;

@end

@implementation GRXLayoutInflater

- (instancetype) initWithData:(NSData*)data {
    self = [super init];
    if(self) {
        _allViewsById = [[NSMutableDictionary alloc] init];
        NSError * error;
        id JSON = [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:&error];
        if(error) {
            NSLog(@"Error parsing layout file, invalid JSON: %@", error);
            return nil;
        }
        [self parseJSON:JSON];
    }
    return self;
}

- (instancetype) initWithBundleFile:(NSString*)filename {
    NSData * data = [NSData dataWithContentsOfFile:filename];
    return [self initWithData:data];
}

- (BOOL) parseJSON:(id)JSON {
    NSDictionary * root = JSON;
    NSAssert([root isKindOfClass:NSDictionary.class],
             @"The layout file must be a dictionary");

    NSDictionary * layout = [JSON objectForKey:@"layout"];
    NSAssert(layout != nil,
             @"'layout' node must be defined in the root");
    NSAssert([layout isKindOfClass:NSDictionary.class],
             @"'layout' node must be a dictionary");

    _rootView = [self parseViewNodeRecursively:layout
                                    parentView:nil];
    return YES;
}


- (UIView*) parseViewNodeRecursively:(NSDictionary*)node
                          parentView:(UIView*)parentView {
    NSString * className = node[@"class"];
    Class viewClass = NSClassFromString(className);
    if(viewClass == nil) {
        NSLog(@"Unknown view class '%@', layout can be badformed", className);
        return nil;
    }

    UIView * view = [[viewClass alloc] initWithFrame:CGRectZero];

    GRXLayoutParams * layoutParams = nil;
    if([parentView.class respondsToSelector:@selector(layoutParamsForSubviewFromDictionary:)]) {
        layoutParams = [parentView.class layoutParamsForSubviewFromDictionary:node];
    } else {
        layoutParams = [GRXLayout layoutParamsForSubviewFromDictionary:node];
    }
    view.grx_layoutParams = layoutParams;

    NSString * identifier = node[@"id"];
    if(identifier != nil) {
        [_allViewsById setObject:view forKey:identifier];
    }

    NSArray * subviews = node[@"subviews"];
    for(NSDictionary * subviewDict in subviews) {
        UIView * subview = [self parseViewNodeRecursively:subviewDict parentView:view];
        if(subview != nil) {
            [view addSubview:subview];
        }
    }

    return view;
}

- (id)viewForIdentifier:(NSString*)identifier {
    return self.allViewsById[identifier];
}

@end