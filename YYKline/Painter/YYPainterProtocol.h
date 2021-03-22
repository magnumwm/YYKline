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
// 获取边界值
+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data;

// 获取辅助展示文字
+ (NSAttributedString *)getText:(YYKlineModel *)model;

@end

@protocol YYVerticalTextPainterProtocol <NSObject>
+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
             minMax:(YYMinMaxModel *)minMaxModel;
@end

@protocol YYCrossLinePainterProtocol <NSObject>

+ (void)drawToLayer:(CALayer *)layer
              point:(CGPoint)point
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
           leftText:(NSAttributedString *)leftText
          rightText:(NSAttributedString *)rightText
           downText:(NSAttributedString *)downText;

@optional
// 获取边界值
+ (YYMinMaxModel *)getMinMaxValue:(YYKlineModel *)data;
@end

@protocol YYCurrentPricePainterProtocol <NSObject>

// 绘制
+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
             models:(NSArray <YYKlineModel *> *)models
             minMax:(YYMinMaxModel *)minMaxModel
            current:(CGFloat)price;
@end

#endif /* YYPainter_h */
