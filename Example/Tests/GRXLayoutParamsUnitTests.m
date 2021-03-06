#import <XCTest/XCTest.h>
#import "GRXTestHelper.h"

#import <GranadaLayout/GRXLayoutInflater.h>
#import <GranadaLayout/GRXRelativeLayout.h>
#import <GranadaLayout/GRXLinearLayout.h>
#define EXP_SHORTHAND

#import <Expecta/Expecta.h>

@interface GRXLayoutParamsUnitTests : XCTestCase

@end

@implementation GRXLayoutParamsUnitTests

- (void)testLinearLayoutParams {
    GRXLayoutInflater *inflater = [GRXTestHelper inflaterForFileWithName:@"linear_vertical_weight.grx"];
    UIView *red = [inflater.rootView grx_findViewWithIdentifier:@"red1"];
    GRXLinearLayoutParams *linearParams = red.grx_linearLayoutParams;
    expect(linearParams).to.beInstanceOf(GRXLinearLayoutParams.class);
    expect(linearParams.width).to.equal(GRXMatchParent);
    expect(linearParams.height).to.equal(80);
    expect(linearParams.margins.top).to.equal(8);

    expect(linearParams.gravity).to.equal(GRXLinearLayoutGravityCenter);
    expect(linearParams.weight).to.equal(30);

    GRXLinearLayoutParams *copy = linearParams.copy;
    expect(copy).to.beInstanceOf(linearParams.class);
    expect(copy.width).to.equal(linearParams.width);
    expect(copy.height).to.equal(linearParams.height);
    expect(copy.margins.top).to.equal(linearParams.margins.top);

    expect(copy.gravity).to.equal(linearParams.gravity);
    expect(copy.weight).to.equal(linearParams.weight);
}

- (void)testRelativeParams {
    GRXLayoutInflater *inflater = [GRXTestHelper inflaterForFileWithName:@"relative_in_relative.grx"];
    UIImageView *image = (UIImageView *) [inflater.rootView grx_findViewWithIdentifier:@"image"];
    UIView *title = [inflater.rootView grx_findViewWithIdentifier:@"title"];
    GRXRelativeLayoutParams *relativeParams = title.grx_relativeLayoutParams;
    expect(relativeParams).to.beInstanceOf(GRXRelativeLayoutParams.class);
    expect(relativeParams.width).to.equal(GRXMatchParent);
    expect(relativeParams.height).to.equal(GRXWrapContent);
    expect([relativeParams hasParentRule:GRXRelativeLayoutParentRuleAlignTop]).to.beTruthy();
    expect([relativeParams hasRule:GRXRelativeLayoutRuleRightOf]).to.beTruthy();
    expect([relativeParams viewForRule:GRXRelativeLayoutRuleRightOf]).to.beIdenticalTo(image);

    GRXRelativeLayoutParams *copy = relativeParams.copy;
    expect(copy).to.beInstanceOf(relativeParams.class);
    expect(copy.width).to.equal(relativeParams.width);
    expect(copy.height).to.equal(relativeParams.height);
    expect(copy.margins.top).to.equal(relativeParams.margins.top);

    for (GRXRelativeLayoutParentRule pr = GRXRelativeLayoutParentRuleAlignLeft;
         pr < GRXRelativeLayoutParentRuleCount;
         ++pr) {
        expect([copy hasParentRule:pr]).to.equal([relativeParams hasParentRule:pr]);
    }

    for (GRXRelativeLayoutRule r = GRXRelativeLayoutRuleLeftOf;
         r < GRXRelativeLayoutRuleCount;
         ++r) {
        expect([copy viewForRule:r]).to.equal([relativeParams viewForRule:r]);
    }
}

@end
