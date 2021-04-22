//
//  YYPainter.h
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#ifndef YYPainter_h
#define YYPainter_h
#import "YYMinMaxModel.h"
#import "YYKlineModel.h"
#import "YYKlineStyleConfig.h"

typedef NS_ENUM(NSUInteger, YYXAxisTimeTextLayout) {
    /// 首尾两端对齐
    YYXAxisTimeTextLayoutEqualBetween,
    /// 等分居中
    YYXAxisTimeTextLayoutEqualCenter,
    /// 等分从头开始绘制
    YYXAxisTimeTextLayoutEqualStart,
    /// 坐标依赖于主图点坐标
    YYXAxisTimeTextLayoutEqualToMainPoint,
};

@class YYMinMaxModel;

@protocol YYPainterProtocol <NSObject>

@required
// 绘制
+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
             models:(NSArray <YYKlineModel *> *)models
             minMax: (YYMinMaxModel *)minMaxModel;

@optional
/// 获取边界值
+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data;
/// 获取触摸点对应的KlineModel
+ (YYKlineModel *)getKlineModel:(CGPoint)touchPoint
                           area:(CGRect)area
                    styleConfig:(YYKlineStyleConfig *)config
                         models:(NSArray<YYKlineModel *> *)models;
/// 获取辅助展示文字
+ (NSAttributedString *)getText:(YYKlineModel *)model;

@end

/// 绘制X轴事件
@protocol YYXAxisTimeTextPainterProtocol <NSObject>

+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
         timestamps:(NSArray *)timestamps
             layout:(YYXAxisTimeTextLayout)layout;
@end

/// 绘制Y轴价格，成交量
@protocol YYVerticalTextPainterProtocol <NSObject>
+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
             minMax:(YYMinMaxModel *)minMaxModel;
@end

/// 绘制十字交叉线
@protocol YYCrossLinePainterProtocol <NSObject>

+ (void)drawToLayer:(CALayer *)layer
              point:(CGPoint)point
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
           leftText:(NSAttributedString * _Nullable)leftText
          rightText:(NSAttributedString * _Nullable)rightText
           downText:(NSAttributedString * _Nullable)downText;

@optional
// 获取边界值
+ (YYMinMaxModel *)getMinMaxValue:(YYKlineModel *)data;
@end

/// 绘制当前价格Painter
@protocol YYCurrentPricePainterProtocol <NSObject>

// 绘制
+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
             models:(NSArray <YYKlineModel *> *)models
             minMax:(YYMinMaxModel *)minMaxModel
            current:(CGFloat)price;
@end

/// 绘制分时图
@protocol YYTimelinePainterProtocol <NSObject>

+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
              total:(NSInteger)total
             models:(NSArray<YYKlineModel*> *)models
             minMax:(YYMinMaxModel *)minMaxModel;

@optional
/// 获取边界值
+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data;
/// 获取触摸点对应的KlineModel
+ (YYKlineModel *)getKlineModel:(CGPoint)touchPoint
                           area:(CGRect)area
                          total:(NSInteger)total
                         models:(NSArray<YYKlineModel*> *)models;
@end



#endif /* YYPainter_h */
