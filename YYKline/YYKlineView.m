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
#import "YYCandlePainter.h"
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
#import "YYCurrentPricelinePainter.h"

@interface YYKlineView() <UIScrollViewDelegate>
{
    UIPinchGestureRecognizer *pinchGesture;
    CGFloat currentStockPrice;
    Class currentPainter;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *painterView;
/// 长按后在这个view上显示十字交叉线
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, assign) CGFloat oldExactOffset; // 旧的scrollview准确位移
@property (nonatomic, assign) CGFloat pinchCenterX;
@property (nonatomic, assign) NSInteger pinchIndex;
@property (nonatomic, assign) NSInteger needDrawStartIndex; // 需要绘制Index开始值
@property (nonatomic, assign) CGFloat oldContentOffsetX; // 旧的contentoffset值
@property (nonatomic, weak) MASConstraint *painterViewXConstraint;

@property (nonatomic) Class<YYPainterProtocol> linePainter;
@property (nonatomic) Class<YYTimelinePainterProtocol> timelinePainter;
@property (nonatomic) Class<YYCrossLinePainterProtocol> crossPainter;
@property (nonatomic) Class<YYCurrentPricePainterProtocol> currentPricePainter;
@end

@implementation YYKlineView

static void dispatch_main_async_safe(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

- (instancetype)initWithStyleConfig:(YYKlineStyleConfig *)config {
    self = [super initWithFrame:CGRectZero];
    if(self) {
        self.styleConfig = config;
        self.linePainter = YYCandlePainter.class;
        self.timelinePainter = YYTimelinePainter.class;
        self.crossPainter = YYCrossLinePainter.class;
        self.currentPricePainter = YYCurrentPricelinePainter.class;
        [self initUI];
    }
    return self;
}

//initWithFrame设置视图比例
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.linePainter = YYCandlePainter.class;
        self.timelinePainter = YYTimelinePainter.class;
        self.crossPainter = YYCrossLinePainter.class;
        self.currentPricePainter = YYCurrentPricelinePainter.class;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = self.styleConfig.backgroundColor;
    // 主图
    [self initScrollView];
    [self initPainterView];
    
    //缩放
    pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(event_pinchMethod:)];
    [_scrollView addGestureRecognizer:pinchGesture];
    
    //长按
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressMethod:)];
    [_scrollView addGestureRecognizer:longPressGesture];
}

- (void)initScrollView {
    _scrollView = [UIScrollView new];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
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

- (void)initTopView {
    self.topView = [UIView new];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.scrollView insertSubview:self.topView aboveSubview:self.painterView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.painterView);
    }];
}

- (void)resetContentOffset {
    self.oldContentOffsetX = 0;
    self.scrollView.contentOffset = CGPointZero;
}

#pragma mark 重绘
- (void)reDrawCandle:(CGFloat)currentPrice {
    currentPainter = self.linePainter;
    currentStockPrice = currentPrice;

    YYKlineStyleConfig *config = self.styleConfig;
    dispatch_main_async_safe(^{
        CGFloat kLineViewWidth = self.rootModel.models.count * config.kLineWidth + (self.rootModel.models.count + 1) * config.kLineGap + 10;
        [self updateScrollViewContentSize];
        CGFloat offset = kLineViewWidth - self.scrollView.frame.size.width;
        if (self.oldContentOffsetX == 0) {
            // 初始展示最新日期的数据
            self.scrollView.contentOffset = CGPointMake(MAX(offset, 0), 0);
        }
//        if (offset == self.oldContentOffsetX) {
            [self calculateNeedDrawModels];
//        }
    });
}

- (void)reDrawTimeline:(CGFloat)currentPrice {
    currentPainter = self.timelinePainter;
    currentStockPrice = currentPrice;

    dispatch_main_async_safe(^{
        self.painterViewXConstraint.offset = 0;
        [self drawWithModels:self.rootModel.models];
    });
}

- (void)calculateNeedDrawModels {
    YYKlineStyleConfig *config = self.styleConfig;
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

    [self drawWithModels:arr];
}

/// 绘制layer
/// @param models 绘制的模型数据数组
- (void)drawWithModels:(NSArray <YYKlineModel *>*)models{
    if (models.count <= 0) {
        return;
    }
    
    YYMinMaxModel *minMax = [YYMinMaxModel new];
    minMax.min = 9999999999999.f;
    if (self.styleConfig.isDrawTimeline) {
        [minMax combine:[self.timelinePainter getMinMaxValue:models]];
    } else {
        [minMax combine:[self.linePainter getMinMaxValue:models]];
    }

    // 移除旧layer
    self.painterView.layer.sublayers = nil;

    YYKlineStyleConfig *config = self.styleConfig;

    CGFloat offsetX = 0;
    if (!self.styleConfig.isDrawTimeline) {
        offsetX = models.firstObject.index * (config.kLineWidth + config.kLineGap) - self.scrollView.contentOffset.x;
        offsetX = MAX(0, offsetX);
    }


    /// K线图主视图
    CGRect mainArea = CGRectMake(offsetX, 0, CGRectGetWidth(self.painterView.bounds), config.mainAreaHeight);
    
    if (self.styleConfig.isDrawTimeline) {
        // 分时主图
        [self.timelinePainter drawToLayer:self.painterView.layer
                                     area:mainArea
                              styleConfig:self.styleConfig
                                    total:self.styleConfig.timelineTotalCount
                                   models:models
                                   minMax:minMax];

        /// 当前基准横线，绘制的是昨收盘价
        if (currentStockPrice > minMax.min && currentStockPrice < minMax.max) {
            // current < min or current > max 不显示
            CGRect currentPriceLineArea = CGRectMake(0, 0, CGRectGetWidth(self.painterView.bounds), config.mainAreaHeight);
            [self.currentPricePainter drawToLayer:self.painterView.layer
                                             area:currentPriceLineArea
                                      styleConfig:self.styleConfig
                                           models:models
                                           minMax:minMax
                                          current:currentStockPrice];
        }
    } else {
        // candle主图
        [self.linePainter drawToLayer:self.painterView.layer
                                 area:mainArea
                          styleConfig:self.styleConfig
                               models:models
                               minMax:minMax];
    }

    // 左侧价格轴
    if (self.styleConfig.drawYAxisPrice) {
        CGRect priceArea = CGRectMake(0, 0, YYKlineLinePriceViewWidth, config.mainAreaHeight);
        [YYVerticalTextPainter drawToLayer:self.painterView.layer
                                      area:priceArea
                               styleConfig:self.styleConfig
                                    minMax:minMax];
    }

    // 时间轴
    // 时间横坐标
    CGRect timelineArea = CGRectMake(offsetX, CGRectGetMaxY(mainArea)+config.mainToTimelineGap, CGRectGetWidth(mainArea), config.timelineAreaHeight);

    if (self.styleConfig.drawXAxisTimeline) {
        if (self.styleConfig.timelineTimestamps.count > 0) {
            // 分时时间轴
            [YYTimePainter drawToLayer:self.painterView.layer
                                  area:timelineArea
                           styleConfig:self.styleConfig
                            timestamps:self.styleConfig.timelineTimestamps layout:(self.styleConfig.timelineTimestamps.count < 4)?YYXAxisTimeTextLayoutEqualBetween:YYXAxisTimeTextLayoutEqualStart];
        } else {
            // 计算需要显示的时间戳区间
            [YYTimePainter drawToLayer:self.painterView.layer
                                  area:timelineArea
                           styleConfig:self.styleConfig
                            timestamps:[self createVisibleTimestamps:models area:timelineArea]
                                layout:YYXAxisTimeTextLayoutEqualToMainPoint];
        }
    }

    // 成交量图
    if (self.styleConfig.drawVolChart) {
        // 成交量视图
        CGRect secondArea = CGRectMake(offsetX, CGRectGetMaxY(timelineArea)+config.timelineToVolumeGap, CGRectGetWidth(mainArea), config.volumeAreaHeight);
        [YYVolPainter drawToLayer:self.painterView.layer
                             area:secondArea
                      styleConfig:self.styleConfig
                           models:models
                           minMax:[YYVolPainter getMinMaxValue:models]];
    }

}

#pragma mark - 计算可见区域的横轴时间坐标
/// 计算可见区域的横轴时间坐标
- (NSArray<YYKlineModel*> *)createVisibleTimestamps:(NSArray <YYKlineModel *> *)models area:(CGRect)area {
    /**
     * 时间绘制规则 展示五个时间标签，标签值为起始时间点和三个四等分点；
     */
    NSInteger gap = (area.size.width/4) / (self.styleConfig.kLineWidth + self.styleConfig.kLineGap);

    NSMutableArray *result = @[].mutableCopy;

    NSUInteger count = models.count;
    for (int i = 1; i < count - 1; i++) {
        BOOL insert = i % gap == 0;
        if (insert) {
            YYKlineModel *model = [models objectAtIndex:i];
            [result addObject:model];
        }
    }
    [result insertObject:models.firstObject atIndex:0];
    if (result.count >= 5) {
        [result replaceObjectAtIndex:result.count-1 withObject:models.lastObject];
    } else {
        [result addObject:models.lastObject];
    }
    return result;
}

#pragma mark -  禁用滚动和缩放
- (void)enableScrollAndZoom:(BOOL)enable {
    self.scrollView.scrollEnabled = enable;
    pinchGesture.enabled = enable;
}

#pragma mark 长按手势执行方法
- (void)event_longPressMethod:(UILongPressGestureRecognizer *)longPress {
    static CGFloat oldPositionX = 0;
    YYKlineStyleConfig *config = self.styleConfig;
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        CGPoint location = [longPress locationInView:self.scrollView];
        // 暂停滑动
        self.scrollView.scrollEnabled = NO;

        CGRect mainArea = CGRectMake(0, 0, CGRectGetWidth(self.painterView.bounds), config.mainAreaHeight+config.mainToTimelineGap+config.timelineAreaHeight+config.timelineToVolumeGap+config.volumeAreaHeight);

        YYKlineModel *model;
        CGPoint crossLineCenterPoint;
        if ([currentPainter isSubclassOfClass:YYCandlePainter.class]) {
            model = [YYCandlePainter getKlineModel:location area:mainArea styleConfig:config models:self.rootModel.models];
            if (!model) return;
            crossLineCenterPoint = model.candleCrossLineCenterPoint;
        } else if([currentPainter isSubclassOfClass:YYTimelinePainter.class]) {
            model = [YYTimelinePainter getKlineModel:location area:mainArea total:config.timelineTotalCount models:self.rootModel.models];
            if (!model) return;
            crossLineCenterPoint = model.timelineCrossLineCenterPoint;
        } else {
            return;
        }

        [self updateLabelText:model];

        // 绘制十字交叉线
        if (longPress.state == UIGestureRecognizerStateBegan) {
            [self initTopView];
        }
        self.topView.layer.sublayers = nil;

        NSString *drawTime = [self.styleConfig.crosslineTimestampFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.Timestamp.doubleValue]];
        NSDictionary *attributes = @{NSForegroundColorAttributeName: config.crossLineTextColor, NSFontAttributeName: config.crosslineTextFont};
        [self.crossPainter drawToLayer:self.topView.layer
                                 point:crossLineCenterPoint
                                  area:mainArea
                           styleConfig:self.styleConfig
                              leftText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", model.Open.floatValue] attributes:attributes]
                             rightText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", model.changePercent] attributes:attributes]
                              downText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", drawTime] attributes:attributes]];
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

        if (self.delegate && [self.delegate respondsToSelector:@selector(yyklineviewEndLongPressChart:)]) {
            [self.delegate yyklineviewEndLongPressChart:self.rootModel.models.lastObject];
        }
    }
}

#pragma mark 缩放执行方法
- (void)event_pinchMethod:(UIPinchGestureRecognizer *)pinch {
    YYKlineStyleConfig *config = self.styleConfig;

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

        CGFloat oldKlineGap = config.kLineGap;
        CGFloat newKlineGap = oldKlineGap * (difValue > 0 ? (1 + YYKlineScaleFactor) : (1 - YYKlineScaleFactor));
        newKlineGap = MIN(newKlineGap, 5);
        if (oldKlineGap <= YYKlineLineMinGap && difValue <= 0) {
            return;
        }

        config.kLineWidth = newKlineWidth;
        config.kLineGap = newKlineGap;

        // 右侧已经没有更多数据时，从右侧开始缩放
        if (((CGRectGetWidth(self.scrollView.bounds) - self.pinchCenterX) / (config.kLineWidth + config.kLineGap)) > self.rootModel.models.count - self.pinchIndex) {
            self.pinchIndex = self.rootModel.models.count -1;
            self.pinchCenterX = CGRectGetWidth(self.scrollView.bounds);
        }
        
        // 左侧已经没有更多数据时，从左侧开始缩放
        if (self.pinchIndex * (config.kLineWidth + config.kLineGap) < self.pinchCenterX) {
            self.pinchIndex = 0;
            self.pinchCenterX = 0;
        }
        
        // 数量很少，少于一屏时，从左侧开始缩放
        if ((CGRectGetWidth(self.scrollView.bounds) / (config.kLineWidth + config.kLineGap)) > self.rootModel.models.count) {
            self.pinchIndex = 0;
            self.pinchCenterX = 0;
        }


        oldScale = pinch.scale;
        NSInteger idx = self.pinchIndex - floor(self.pinchCenterX / (config.kLineGap + config.kLineWidth));
        CGFloat offset = idx * (config.kLineGap + config.kLineWidth);
//        [self.rootModel calculateNeedDrawTimeModel];
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
}

- (void)updateScrollViewContentSize {
    YYKlineStyleConfig *config = self.styleConfig;
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
