//
//  YYKlineView.m
//  YYKline
//
//  Copyright © 2016年 WillkYang. All rights reserved.
//

#import "YYKlineView.h"
#import "Masonry.h"
#import "YYKlineStyleConfig.h"
#import "YYKlineRootModel.h"
#import "YYPainterProtocol.h"
//#import "YYCandlePainter.h"
#import "YYMAPainter.h"
#import "YYVolPainter.h"
#import "YYMACDPainter.h"
//#import "YYKDJPainter.h"
#import "YYVerticalTextPainter.h"
#import "YYTimePainter.h"
//#import "YYWRPainter.h"
//#import "YYRSIPainter.h"
//#import "YYEMAPainter.h"
//#import "YYBOLLPainter.h"
#import "YYTimelinePainter.h"
#import "YYCrossLinePainter.h"

@interface YYKlineView() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *painterView;
@property (nonatomic, strong) UIView *topView; // 长按后在这个view上显示十字交叉线
//@property (nonatomic, strong) UIView *rightView;
//@property (nonatomic, strong) UILabel *topLabel;
//@property (nonatomic, strong) UILabel *middleLabel;
//@property (nonatomic, strong) UILabel *bottomLabel;
//@property (nonatomic, strong) UIView *verticalView; // 长按后显示的View

@property (nonatomic, assign) CGFloat oldExactOffset; // 旧的scrollview准确位移
@property (nonatomic, assign) CGFloat pinchCenterX;
@property (nonatomic, assign) NSInteger pinchIndex;
@property (nonatomic, assign) NSInteger needDrawStartIndex; // 需要绘制Index开始值
@property (nonatomic, assign) CGFloat oldContentOffsetX; // 旧的contentoffset值
@property (nonatomic, assign) CGFloat oldScale; // 旧的缩放值，捏合
@property (nonatomic, weak) MASConstraint *painterViewXConstraint;
@property (nonatomic, assign) CGFloat mainViewRatio; // 第一个View的高所占比例
@property (nonatomic, assign) CGFloat volumeViewRatio; // 第二个View(成交量)的高所占比例
@end

@implementation YYKlineView

static void dispatch_main_async_safe(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}


//initWithFrame设置视图比例
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.mainViewRatio = YYKlineStyleConfig.sharedConfig.kLineMainViewRadio;
        self.volumeViewRatio = YYKlineStyleConfig.sharedConfig.kLineVolumeViewRadio;
//        self.indicator1Painter = YYMAPainter.class;
//        self.indicator2Painter = YYMACDPainter.class;
        self.crossPainter = YYCrossLinePainter.class;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = YYKlineStyleConfig.sharedConfig.backgroundColor;
    // 主图
    [self initScrollView];
    [self initPainterView];
//    [self initRightView];
//    [self initLabel];
    
    //缩放
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(event_pinchMethod:)];
    [_scrollView addGestureRecognizer:pinchGesture];
    
    //长按
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressMethod:)];
    [_scrollView addGestureRecognizer:longPressGesture];
}

- (void)initScrollView {
    _scrollView = [UIScrollView new];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;

    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)initPainterView {
    self.painterView = [[UIView alloc] init];
    [self.scrollView addSubview:self.painterView];
    [self.painterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.equalTo(self.scrollView);
        self.painterViewXConstraint = make.left.equalTo(self.scrollView);
    }];
}

//- (void)initRightView {
//    self.rightView = [[UIView alloc] init];
//    self.rightView.backgroundColor = YYKlineStyleConfig.sharedConfig.assistBackgroundColor;
//    [self addSubview:self.rightView];
//    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.right.bottom.equalTo(self);
//        make.width.equalTo(@YYKlineLinePriceViewWidth);
//    }];
//}

- (void)initTopView {
    self.topView = [UIView new];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.scrollView insertSubview:self.topView aboveSubview:self.painterView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.painterView);
    }];
}

//- (void)initLabel {
//    UILabel *label1 = [UILabel new];
//    label1.font = [UIFont systemFontOfSize:10];
//    [self addSubview:label1];
//    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self);
//        make.left.equalTo(self);
//        make.top.equalTo(self).offset(5);
//        make.height.equalTo(@10);
//    }];
//    self.topLabel = label1;
//
//    UILabel *label2 = [UILabel new];
//    label2.font = [UIFont systemFontOfSize:10];
//    [self addSubview:label2];
//    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self);
//        make.left.equalTo(self);
//        make.top.equalTo(self.mas_bottom).multipliedBy(self.mainViewRatio).offset(5);
//        make.height.equalTo(@10);
//    }];
//    self.middleLabel = label2;
//
//    UILabel *label3 = [UILabel new];
//    label3.font = [UIFont systemFontOfSize:10];
//    [self addSubview:label3];
//    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self);
//        make.left.equalTo(self);
//        make.top.equalTo(self.mas_bottom).multipliedBy(self.mainViewRatio + self.volumeViewRatio).offset(5);
//        make.height.equalTo(@10);
//    }];
//    self.bottomLabel = label3;
//}

#pragma mark 重绘
- (void)reDraw {
    YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
    dispatch_main_async_safe(^{
        CGFloat kLineViewWidth = self.rootModel.models.count * config.kLineWidth + (self.rootModel.models.count + 1) * config.kLineGap + 10;
        [self updateScrollViewContentSize];
        CGFloat offset = kLineViewWidth - self.scrollView.frame.size.width;
        self.scrollView.contentOffset = CGPointMake(MAX(offset, 0), 0);
        if (offset == self.oldContentOffsetX) {
            [self calculateNeedDrawModels];
        }
    });
}

- (void)calculateNeedDrawModels {
    YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
    CGFloat lineGap = config.kLineGap;
    CGFloat lineWidth = config.kLineWidth;
    
    //数组个数
    NSInteger needDrawKlineCount = ceil((CGRectGetWidth(self.scrollView.frame))/(lineGap+lineWidth)) + 1;
    CGFloat scrollViewOffsetX = self.scrollView.contentOffset.x < 0 ? 0 : self.scrollView.contentOffset.x;
    NSUInteger leftArrCount = floor(scrollViewOffsetX / (lineGap + lineWidth));
    self.needDrawStartIndex = leftArrCount;
    
    NSArray *arr;
    //赋值数组
    if(self.needDrawStartIndex < self.rootModel.models.count) {
        if(self.needDrawStartIndex + needDrawKlineCount < self.rootModel.models.count) {
            arr = [self.rootModel.models subarrayWithRange:NSMakeRange(self.needDrawStartIndex, needDrawKlineCount)];
        } else {
            arr = [self.rootModel.models subarrayWithRange:NSMakeRange(self.needDrawStartIndex, self.rootModel.models.count - self.needDrawStartIndex)];
        }
    }
    
    [self drawWithModels: arr];
}

- (void)drawWithModels:(NSArray <YYKlineModel *>*)models {
    if (models.count <= 0) {
        return;
    }
    
    YYMinMaxModel *minMax = [YYMinMaxModel new];
    minMax.min = 9999999999999.f;
    [minMax combine:[self.linePainter getMinMaxValue: models]];
//    if (self.indicator1Painter) {
//        [minMax combine:[self.indicator1Painter getMinMaxValue: models]];
//    }

    // 移除旧layer
    self.painterView.layer.sublayers = nil;
//    self.rightView.layer.sublayers = nil;

    YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;

    CGFloat offsetX = models.firstObject.index * (config.kLineWidth + config.kLineGap) - self.scrollView.contentOffset.x;

    CGRect mainArea = CGRectMake(offsetX, 0, CGRectGetWidth(self.painterView.bounds), config.mainAreaHeight);

    CGRect timelineArea = CGRectMake(offsetX, CGRectGetMaxY(mainArea)+config.mainToTimelineGap, CGRectGetWidth(mainArea), config.timelineAreaHeight);

    CGRect secondArea = CGRectMake(offsetX, CGRectGetMaxY(timelineArea)+config.timelineToVolumeGap, CGRectGetWidth(mainArea), config.volumeAreaHeight);


//    CGRect thirdArea = CGRectMake(offsetX, CGRectGetMaxY(secondArea) + 20, CGRectGetWidth(mainArea), CGRectGetHeight(self.painterView.bounds) * (1 - self.mainViewRatio - self.volumeViewRatio) - 20);
    
    // 时间轴
    [YYTimePainter drawToLayer:self.painterView.layer area:timelineArea models:models minMax:minMax];
//    // 右侧价格轴
//    [YYVerticalTextPainter drawToLayer: self.rightView.layer area: CGRectMake(0, 20, YYKlineLinePriceViewWidth, CGRectGetHeight(mainArea)) minMax:minMax];
//    // 右侧成交量轴
//    [YYVerticalTextPainter drawToLayer: self.rightView.layer area: CGRectMake(0, CGRectGetMaxY(mainArea)+20, YYKlineLinePriceViewWidth, CGRectGetHeight(secondArea)) minMax:[YYVolPainter getMinMaxValue:models]];
//    // 右侧副图
//    [YYVerticalTextPainter drawToLayer: self.rightView.layer area: CGRectMake(0, thirdArea.origin.y, YYKlineLinePriceViewWidth, CGRectGetHeight(thirdArea)) minMax:[YYMACDPainter getMinMaxValue:models]];
    
    // 主图
    [self.linePainter drawToLayer: self.painterView.layer area: mainArea models: models minMax: minMax];
    // 主图指标图
//    if (self.indicator1Painter) {
//        [self.indicator1Painter drawToLayer: self.painterView.layer area: mainArea models: models minMax: minMax];
//    }
    // 成交量图
    [YYVolPainter drawToLayer: self.painterView.layer area: secondArea models:models minMax:[YYVolPainter getMinMaxValue:models]];
    // 副图指标
//    [self.indicator2Painter drawToLayer: self.painterView.layer area:thirdArea models:models minMax:[self.indicator2Painter getMinMaxValue:models]];
    // 文字
//    [self updateLabelText: models.lastObject];
}

#pragma mark 长按手势执行方法
- (void)event_longPressMethod:(UILongPressGestureRecognizer *)longPress {
    static CGFloat oldPositionX = 0;
    YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        CGPoint location = [longPress locationInView:self.scrollView];
        if(ABS(oldPositionX - location.x) < (config.kLineWidth + config.kLineGap)/2) {
            return;
        }
        // 暂停滑动
        self.scrollView.scrollEnabled = NO;
        oldPositionX = location.x;
        NSInteger idx = ABS(floor(location.x / (config.kLineWidth + config.kLineGap)));
        idx = MIN(idx, self.rootModel.models.count - 1);

        YYKlineModel *model =  self.rootModel.models[idx];

        [self updateLabelText:model];

        // 绘制十字交叉线
        if (longPress.state == UIGestureRecognizerStateBegan) {
            [self initTopView];
        }
        self.topView.layer.sublayers = nil;
        // vertical line start x
        CGFloat offsetX = idx * (config.kLineWidth + config.kLineGap) + (config.kLineWidth-config.kLineGap)/2.f - self.scrollView.contentOffset.x;

        CGRect mainArea = CGRectMake(0, 0, CGRectGetWidth(self.painterView.bounds), config.mainAreaHeight+config.mainToTimelineGap+config.timelineAreaHeight);

        // offsetY设为当前model的close price位置
        CGFloat offsetY = model.y;

        NSDictionary *attributes = @{NSForegroundColorAttributeName: config.crossLineTextColor, NSFontAttributeName: config.crosslineTextFont};
        [self.crossPainter drawToLayer:self.topView.layer
                                 point:CGPointMake(offsetX, offsetY)
                                  area:mainArea
                              leftText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f", model.Volume.floatValue] attributes:attributes]
                             rightText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", model.changePercent] attributes:attributes]];
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded ||
       longPress.state == UIGestureRecognizerStateCancelled) {
        // 取消crossLine
        self.topView.layer.sublayers = nil;
        self.topView = nil;
        oldPositionX = 0;
        // 恢复scrollView的滑动
        self.scrollView.scrollEnabled = YES;
        [self updateLabelText:self.rootModel.models.lastObject];
    }
}

#pragma mark 缩放执行方法
- (void)event_pinchMethod:(UIPinchGestureRecognizer *)pinch {
    YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;

    if (pinch.state == UIGestureRecognizerStateBegan) {
        self.scrollView.scrollEnabled = NO;
        CGPoint p1 = [pinch locationOfTouch:0 inView:self.painterView];
        CGPoint p2 = [pinch locationOfTouch:1 inView:self.painterView];
        self.pinchCenterX = (p1.x+p2.x)/2;
        self.pinchIndex = ABS(floor((self.pinchCenterX + self.scrollView.contentOffset.x) / (config.kLineWidth + config.kLineGap)));
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        self.scrollView.scrollEnabled = YES;
    }
    static CGFloat oldScale = 1.0f;
    CGFloat difValue = pinch.scale - oldScale;
    if(ABS(difValue) > YYKlineScaleBound) {
        CGFloat oldKlineWidth = config.kLineWidth;
        CGFloat newKlineWidth = oldKlineWidth * (difValue > 0 ? (1 + YYKlineScaleFactor) : (1 - YYKlineScaleFactor));
        if (oldKlineWidth <= config.klineLineMinWidth && difValue <= 0) {
            return;
        }
        
        // 右侧已经没有更多数据时，从右侧开始缩放
        if (((CGRectGetWidth(self.scrollView.bounds) - self.pinchCenterX) / (newKlineWidth + config.kLineGap)) > self.rootModel.models.count - self.pinchIndex) {
            self.pinchIndex = self.rootModel.models.count -1;
            self.pinchCenterX = CGRectGetWidth(self.scrollView.bounds);
        }
        
        // 左侧已经没有更多数据时，从左侧开始缩放
        if (self.pinchIndex * (newKlineWidth + config.kLineGap) < self.pinchCenterX) {
            self.pinchIndex = 0;
            self.pinchCenterX = 0;
        }
        
        // 数量很少，少于一屏时，从左侧开始缩放
        if ((CGRectGetWidth(self.scrollView.bounds) / (newKlineWidth + config.kLineGap)) > self.rootModel.models.count) {
            self.pinchIndex = 0;
            self.pinchCenterX = 0;
        }

        config.kLineWidth = newKlineWidth;
        oldScale = pinch.scale;
        NSInteger idx = self.pinchIndex - floor(self.pinchCenterX / (config.kLineGap + config.kLineWidth));
        CGFloat offset = idx * (config.kLineGap + config.kLineWidth);
        [self.rootModel calculateNeedDrawTimeModel];
        [self updateScrollViewContentSize];
        self.scrollView.contentOffset = CGPointMake(offset, 0);
        // scrollview的contentsize小于frame时，不会触发scroll代理，需要手动调用
        if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
            [self scrollViewDidScroll:self.scrollView];
        }
    }
}

- (void)updateLabelText:(YYKlineModel *)m {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yyklineviewUpdateText:)]) {
        [self.delegate yyklineviewUpdateText:m];
    }
//    if (self.indicator1Painter) {
//        self.topLabel.attributedText = [self.indicator1Painter getText: m];
//    } else {
//        self.topLabel.attributedText = m.V_Price;
//    }
//    self.middleLabel.attributedText = m.V_Volume;
//    self.bottomLabel.attributedText = [self.indicator2Painter getText: m];
}

- (void)updateScrollViewContentSize {
    YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
    CGFloat contentSizeW = self.rootModel.models.count * config.kLineWidth + (self.rootModel.models.count -1) * config.kLineGap;
    self.scrollView.contentSize = CGSizeMake(contentSizeW, self.scrollView.contentSize.height);
}

#pragma mark - UIScrollView代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView.contentOffset.x < 0) {
        self.painterViewXConstraint.offset = 0;
    } else {
        self.painterViewXConstraint.offset = scrollView.contentOffset.x;
    }
    self.oldContentOffsetX = self.scrollView.contentOffset.x;
    [self calculateNeedDrawModels];
}

@end
