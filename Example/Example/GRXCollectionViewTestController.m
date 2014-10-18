#import "GRXCollectionViewTestController.h"
#import <GRXLayoutInflater.h>
#import "GRXTextGenerator.h"

@interface GRXCollectionViewTestController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) NSMutableArray *cellDatas;

@end

@interface GRXInflatedCellData : UICollectionViewCell

@property (nonatomic) NSString *title, *subtitle, *message;
@property (nonatomic) BOOL showImage;

@end

@interface GRXInflatedCell : UICollectionViewCell

@property (nonatomic) GRXInflatedCellData *data;
@property (nonatomic) GRXLayout *root;
@property (nonatomic) UIImageView *image;
@property (nonatomic) UITextView *title, *message;
@property (nonatomic) UILabel *subtitle;

+ (CGSize)sizeForData:(GRXInflatedCellData *)data;

@end


@implementation GRXCollectionViewTestController

- (instancetype)init {
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    return [self initWithCollectionViewLayout:flow];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        NSUInteger numberOfItems = 200;// + arc4random_uniform(200);
        self.cellDatas = [NSMutableArray arrayWithCapacity:numberOfItems];
        for (NSUInteger i = 0; i < numberOfItems; ++i) {
            GRXInflatedCellData *data = [[GRXInflatedCellData alloc] init];

            data.title = [GRXTextGenerator stringWithMinimumWords:5 maxWords:16];
            data.subtitle = [GRXTextGenerator stringWithMinimumWords:4 maxWords:8];
            data.message = [GRXTextGenerator stringWithMaxLength:100 emptyProbability:0.5];
            data.showImage = arc4random() % 2;

            [self.cellDatas addObject:data];
        }
    }
    return self;
}

+ (NSString *)selectionTitle {
    return @"UICollectionViewCell example";
}

+ (NSString *)selectionDetail {
    return @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.collectionView registerClass:GRXInflatedCell.class
            forCellWithReuseIdentifier:NSStringFromClass(GRXInflatedCell.class)];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.cellDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GRXInflatedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(GRXInflatedCell.class)
                                                                      forIndexPath:indexPath];
    GRXInflatedCellData *data = self.cellDatas[indexPath.row];
    cell.data = data;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    GRXInflatedCellData *data = self.cellDatas[indexPath.row];
    CGSize size = [GRXInflatedCell sizeForData:data];

    NSLog(@"[%zd] -> %.0f, %.0f", indexPath.row, size.width, size.height);

    return size;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 0, 0, 8);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

@end

@implementation GRXInflatedCellData
@end

@implementation GRXInflatedCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        GRXLayoutInflater *inflater = [[GRXLayoutInflater alloc] initWithFile:@"cell_test.grx"
                                                                   fromBundle:[NSBundle bundleForClass:self.class]];
        self.root = inflater.rootView;
        self.image = [inflater viewForIdentifier:@"image"];
        self.image.backgroundColor = [UIColor blueColor];
        self.image.contentMode = UIViewContentModeScaleAspectFit;

        __weak GRXInflatedCell *weakSelf = self;
        self.image.grx_measurementBlock = ^CGSize(GRXMeasureSpec wspec, GRXMeasureSpec hspec) {
            GRXMeasureSpec propHSpec = GRXMeasureSpecMake(wspec.value*1.1, wspec.mode);
            return [weakSelf.image grx_measureForWidthSpec:wspec heightSpec:propHSpec]; // this forces the image to be (w, w*1.1)
        };

        self.title = [inflater viewForIdentifier:@"title"];
        self.subtitle = [inflater viewForIdentifier:@"subtitle"];
        self.subtitle.numberOfLines = 3;

        self.message = [inflater viewForIdentifier:@"message"];

        [self.contentView addSubview:self.root];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setData:(GRXInflatedCellData *)data {
    _data = data;

    self.title.attributedText = [[NSAttributedString alloc] initWithString:data.title];
    self.subtitle.text = data.subtitle;

    self.message.attributedText = [[NSAttributedString alloc] initWithString:data.message];
    self.message.grx_visibility = data.message.length == 0 ? GRXVisibilityGone : GRXVisibilityVisible;

    self.image.image = [UIImage imageNamed:@"lab.png"];
    self.image.grx_visibility = data.showImage ? GRXVisibilityVisible : GRXVisibilityGone;

    [self.root setNeedsLayout];
}

+ (CGSize)sizeForData:(GRXInflatedCellData *)data {
    static GRXInflatedCell *staticCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticCell = [[GRXInflatedCell alloc] initWithFrame:CGRectZero];
    });
    staticCell.data = data;

    [staticCell.root grx_invalidateMeasuredSize];
    [staticCell setNeedsLayout];
    [staticCell layoutIfNeeded];

    return staticCell.root.size;
}

@end