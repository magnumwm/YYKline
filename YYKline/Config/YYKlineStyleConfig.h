//
//  YYKlineStyleConfig.h
//  YYKline
//
//  Created by aqumon on 2021/2/20.
//  Copyright © 2021 WillkYang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYKlineStyleConfig : NSObject
+ (instancetype)sharedConfig;

- (void)loadDefault;

// MARK: 颜色
/**
 *  所有图表的背景颜色
 */
@property (nonatomic, strong) UIColor * backgroundColor;

/**
 *  辅助背景色
 */
@property (nonatomic, strong) UIColor * assistBackgroundColor;

/**
 *  涨的颜色
 */
@property (nonatomic, strong) UIColor * upColor;

/**
 *  跌的颜色
 */
@property (nonatomic, strong) UIColor * downColor;

/**
 *  主文字颜色
 */
@property (nonatomic, strong) UIColor * mainTextColor;

/**
 *  时间轴的颜色
 */
@property (nonatomic, strong) UIColor * timeLineColor;

/**
 *  分时线的颜色
 */
@property (nonatomic, strong) UIColor * timeLineLineColor;

/**
 *  长按时线的颜色
 */
@property (nonatomic, strong) UIColor * crossLineColor;

/**
 *  cross line label的颜色
 */
@property (nonatomic, strong) UIColor * crossLineTextColor;

/**
 *  cross line label背景颜色
 */
@property (nonatomic, strong) UIColor * crossLineTextBackgroundColor;

/**
 *  cross line 中心圆点颜色
 */
@property (nonatomic, strong) UIColor * crossLineCenterColor;

/**
 *  cross line 中心阴影颜色
 */
@property (nonatomic, strong) UIColor * crossLineCenterShadowColor;

/**
 *  辅助线颜色1
 */
@property (nonatomic, strong) UIColor * line1Color;

/**
 *  辅助线颜色2
 */
@property (nonatomic, strong) UIColor * line2Color;

/**
 *  辅助线颜色3
 */
@property (nonatomic, strong) UIColor * line3Color;

/**
 *  分时图渐变色start
 */
@property (nonatomic, strong) UIColor *timelineGradientStartColor;
/**
 *  分时图渐变色end
 */
@property (nonatomic, strong) UIColor *timelineGradientEndColor;

/**
 *  成交量柱状图up
 */
@property (nonatomic, strong) UIColor *volumeUpColor;
/**
 *  成交量柱状图down
 */
@property (nonatomic, strong) UIColor *volumeDownColor;

// MARK: 字体
/**
 *  时间轴字体
 */
@property (nonatomic, strong) NSString *timelineFontName;
@property (nonatomic, strong) UIFont *timelineFont;

/**
 *  K线图分类字体（分时/日k/月k）
 */
@property (nonatomic, strong) UIFont *klineCategoryFont;

/**
 *  Kline 属性字体（价格/涨跌额/涨跌幅/成交量）
 */
@property (nonatomic, strong) UIFont *klinePropertyTextFont;
/**
 *  Kline 属性值字体（价格/涨跌额/涨跌幅/成交量）
 */
@property (nonatomic, strong) UIFont *klinePropertyValueFont;

/**
 *  Kline cross line label font
 */
@property (nonatomic, strong) UIFont *crosslineTextFont;

// MARK: 布局
/**
 *  K线图线宽，默认1
 */
@property (nonatomic, assign) CGFloat kLineLineWidth;
/**
 *  K线图最小线宽，默认1
 */
@property (nonatomic, assign) CGFloat klineLineMinWidth;
/**
 *  K线图最大线宽，默认20
 */
@property (nonatomic, assign) CGFloat klineLineMaxWidth;
/**
 *  分时线线宽，默认2.4
 */
@property (nonatomic, assign) CGFloat kTimelineLineWidth;
/**
 *  K线图的宽度，默认20
 */
@property (nonatomic, assign) CGFloat kLineWidth;
/**
 *  K线图的间隔，默认1
 */
@property (nonatomic, assign) CGFloat kLineGap;
/**
 *  K线图蜡烛圆角
 */
@property (nonatomic, assign) CGFloat kCandleRadius;
/**
 *  成交量bar圆角
 */
@property (nonatomic, assign) CGFloat kVolumeBarRadius;
/**
 *  MainView的高度占比,默认为0.5
 */
@property (nonatomic, assign) CGFloat kLineMainViewRadio;

/**
 *  VolumeView的高度占比,默认为0.2
 */
@property (nonatomic, assign) CGFloat kLineVolumeViewRadio;
/**
 *  K线图的crossLine宽度，默认1
 */
@property (nonatomic, assign) CGFloat kLineCrosslineWidth;
/**
 *  K线图的crossLine中点半径，默认4
 */
@property (nonatomic, assign) CGFloat kLineCrossCenterRadius;
/**
 *  K线图的crossLine 文字最大宽度
 */
@property (nonatomic, assign) CGFloat kLineCrossTextMaxWidth;
/**
 *  K线图的crossLine 文字高度
 */
@property (nonatomic, assign) CGFloat kLineCrossTextHeight;
/**
 *  K线图的crossLine 文字EdgeInset
 */
@property (nonatomic, assign) UIEdgeInsets kLineCrossTextInset;
/**
 *  K线图区域和时间轴区域间距
 */
@property (nonatomic, assign) CGFloat mainToTimelineGap;
/**
 *  时间轴区域和成交量间距
 */
@property (nonatomic, assign) CGFloat timelineToVolumeGap;
/**
 *  K线图区域高度
 */
@property (nonatomic, assign) CGFloat mainAreaHeight;
/**
 *  成交量区域高度
 */
@property (nonatomic, assign) CGFloat volumeAreaHeight;
/**
 *  时间轴区域高度
 */
@property (nonatomic, assign) CGFloat timelineAreaHeight;


// MARK: 股票市场绘制参数
/// 股票市场每天每时数据量总数 A股：241， 港股：331，美股：391
@property (nonatomic, assign) NSInteger timelineTotalCount;
/// 是否绘制分时
@property (nonatomic, assign) BOOL isDrawTimeline;
/// 分时横坐标时间轴数组
@property (nonatomic, copy) NSArray<NSString*> *timelineTimestamps;
/// 横轴表时间轴DateFormatter
@property (nonatomic, strong) NSDateFormatter *timestampFormatter;
@end

NS_ASSUME_NONNULL_END
