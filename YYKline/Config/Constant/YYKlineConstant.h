//
//  YYKlineConstant.h
//  YYKline
//
//  Copyright © 2016年 WillkYang. All rights reserved.
//

#ifndef YYKlineConstant_h
#define YYKlineConstant_h

#endif /* YYKlineConstant_h */

/**
 *  K线图Y的View的宽度
 */
#define YYKlineLinePriceViewWidth 30

/**
 *  K线最大的宽度
 */
#define YYKlineLineMaxWidth 20

/**
 *  K线图最小的宽度
 */
#define YYKlineLineMinWidth 0.1

/**
 *  K线图最大的间隔
 */
#define YYKlineLineMaxGap 5

/**
 *  K线图最小的间隔
 */
#define YYKlineLineMinGap 0.01

/**
 *  K线图缩放界限
 */
#define YYKlineScaleBound 0.1

/**
 *  K线的缩放因子
 */
#define YYKlineScaleFactor 0.07

/**
 *  长按时的线的宽度
 */
#define YYKlineLongPressVerticalViewWidth 0.5

/**
 *  上下影线宽度
 */
#define YYKlineLineWidth 1

// Kline种类
typedef NS_ENUM(NSInteger, YYKlineType) {
    YYKlineTypeKline = 1, //K线
    YYKlineTypeTimeLine,  //分时图
    YYKlineTypeIndicator
};
