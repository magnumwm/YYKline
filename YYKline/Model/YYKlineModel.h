//
//  YYKlineModel.h
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "YYIndicatorModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYKlineModel : NSObject

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, weak) YYKlineModel *PrevModel;

@property (nonatomic, assign) double Timestamp;
@property (nonatomic, assign) double Open;
@property (nonatomic, assign) double Close;
@property (nonatomic, assign) double High;
@property (nonatomic, assign) double Low;
@property (nonatomic, assign) double Volume;
/**
 * 涨跌幅
 */
@property (nonatomic, strong) NSString *changePercent;
/**
 * 涨跌额
 */
@property (nonatomic, strong) NSString *changeAmount;

@property (nonatomic, strong) YYMACDModel *MACD;
@property (nonatomic, strong) YYKDJModel *KDJ;
@property (nonatomic, strong) YYMAModel *MA;
@property (nonatomic, strong) YYEMAModel *EMA;
@property (nonatomic, strong) YYRSIModel *RSI;
@property (nonatomic, strong) YYBOLLModel *BOLL;
@property (nonatomic, strong) YYWRModel *WR;

@property (nonatomic, assign) BOOL isUp;

@property (nonatomic, copy) NSString *V_Date;
@property (nonatomic, copy) NSString *V_HHMM;
@property (nonatomic, copy) NSAttributedString *V_Price;
@property (nonatomic, copy) NSAttributedString *V_MA;
@property (nonatomic, copy) NSAttributedString *V_EMA;
@property (nonatomic, copy) NSAttributedString *V_BOLL;
@property (nonatomic, copy) NSAttributedString *V_Volume;
@property (nonatomic, copy) NSAttributedString *V_MACD;
@property (nonatomic, copy) NSAttributedString *V_KDJ;
@property (nonatomic, copy) NSAttributedString *V_WR;
@property (nonatomic, copy) NSAttributedString *V_RSI;

// MARK: Drawable
/**
 * 主图中的绘制中点
 */
@property (nonatomic, assign) CGPoint mainCenterPoint;
/**
 * 分时图十字交叉线中点
 */
@property (nonatomic, assign) CGPoint timelineCrossLineCenterPoint;
/**
 * 蜡烛图十字交叉线中点
 */
@property (nonatomic, assign) CGPoint candleCrossLineCenterPoint;
@end

NS_ASSUME_NONNULL_END
