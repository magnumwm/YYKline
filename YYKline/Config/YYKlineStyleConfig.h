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
+ (instancetype)config;

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
@property (nonatomic, strong) UIColor * crossLineLabelColor;

/**
 *  cross line label背景颜色
 */
@property (nonatomic, strong) UIColor * crossLineLabelBackgroundColor;

/**
 *  cross line 中心圆点颜色
 */
@property (nonatomic, strong) UIColor * crossLineCenterColor;

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

// MARK: 字体
/**
 *  时间轴字体
 */
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
@property (nonatomic, strong) UIFont *crosslineLabelFont;

// MARK: 布局
/**
 *  K线图线宽，默认1
 */
@property (nonatomic, assign) CGFloat kLineLineWidth;
/**
 *  K线图的宽度，默认20
 */
@property (nonatomic, assign) CGFloat kLineWidth;
/**
 *  K线图的间隔，默认1
 */
@property (nonatomic, assign) CGFloat kLineGap;
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
@end

NS_ASSUME_NONNULL_END
