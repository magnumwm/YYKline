//
//  YYCandlePainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYCandlePainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYCandlePainter

+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
//    if (!data[0] ||
//        [data[0].Low isKindOfClass:NSNull.class] ||
//        [data[0].High isKindOfClass:NSNull.class] ||
//        [data[0].Open isKindOfClass:NSNull.class] ||
//        [data[0].Close isKindOfClass:NSNull.class]) {
//        NSLog(@"data error: %@", data);
//    }
    __block CGFloat minAssert = data[0].Low.floatValue;
    __block CGFloat maxAssert = data[0].High.floatValue;
    [data enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        maxAssert = MAX(maxAssert, m.High.floatValue);
        minAssert = MIN(minAssert, m.Low.floatValue);
    }];
    return [YYMinMaxModel modelWithMin:minAssert max:maxAssert];
}

+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
             models:(NSArray <YYKlineModel *> *)models
             minMax: (YYMinMaxModel *)minMaxModel {
    if(!models) {
        return;
    }
    CGFloat maxH = CGRectGetHeight(area);
    CGFloat unitValue = maxH/minMaxModel.distance;

    YYCandlePainter *sublayer = [[YYCandlePainter alloc] init];
    sublayer.frame = area;
    sublayer.contentsScale = UIScreen.mainScreen.scale;
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (!m ||
//            [m.Low isKindOfClass:NSNull.class] ||
//            [m.High isKindOfClass:NSNull.class] ||
//            [m.Open isKindOfClass:NSNull.class] ||
//            [m.Close isKindOfClass:NSNull.class]) {
//            NSLog(@"data error: %@", m);
//        }

        CGFloat w = config.kLineWidth;
        CGFloat x = idx * (w + config.kLineGap);
        CGFloat centerX = x+w/2.f-config.kLineGap/2.f;
        CGPoint highPoint = CGPointMake(centerX, maxH - (m.High.floatValue - minMaxModel.min)*unitValue);
        CGPoint lowPoint = CGPointMake(centerX, maxH - (m.Low.floatValue - minMaxModel.min)*unitValue);

        // 开收
        CGFloat h = fabsf(m.Open.floatValue - m.Close.floatValue) * unitValue;
        CGFloat y =  maxH - (MAX(m.Open.floatValue, m.Close.floatValue) - minMaxModel.min) * unitValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w - config.kLineGap, h) cornerRadius:config.kCandleRadius];

        // YYKlineModel 赋值
//        m.lowPoint = lowPoint;
//        m.highPoint = highPoint;
        CGFloat candleCenterY = maxH - (m.Close.floatValue - minMaxModel.min) * unitValue;
        m.candleCrossLineCenterPoint = CGPointMake(centerX, candleCenterY);
        
        [path moveToPoint:lowPoint];
        [path addLineToPoint:CGPointMake(centerX, y+h)];
        [path moveToPoint:highPoint];
        [path addLineToPoint:CGPointMake(centerX, y)];
        
        
        CAShapeLayer *l = [CAShapeLayer layer];
        l.contentsScale = UIScreen.mainScreen.scale;
        l.path = path.CGPath;
        l.lineWidth = config.kLineLineWidth;
        l.strokeColor = m.isUp ? config.upColor.CGColor : config.downColor.CGColor;
        l.fillColor =   m.isUp ? config.upColor.CGColor : config.downColor.CGColor;
        [sublayer addSublayer:l];
    }];
    [layer addSublayer:sublayer];
}

@end
