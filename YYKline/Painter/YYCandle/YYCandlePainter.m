//
//  YYCandlePainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYCandlePainter.h"
#import "YYKlineStyleConfig.h"
#import "YYKlineRootModel.h"

@implementation YYCandlePainter

+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
    __block CGFloat minAssert = data[0].Low;
    __block CGFloat maxAssert = data[0].High;
    [data enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        maxAssert = MAX(maxAssert, m.High);
        minAssert = MIN(minAssert, m.Low);
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
        if (m.Open > kStockPriceNullValue &&
            m.Close > kStockPriceNullValue) {
            CGFloat w = config.kLineWidth;
            CGFloat x = idx * (w + config.kLineGap);
            CGFloat centerX = x+w/2.f-config.kLineGap/2.f;
            CGPoint highPoint = CGPointMake(centerX, maxH - (m.High - minMaxModel.min)*unitValue);
            CGPoint lowPoint = CGPointMake(centerX, maxH - (m.Low - minMaxModel.min)*unitValue);

            // 开收
            CGFloat h = fabs(m.Open - m.Close) * unitValue;
            CGFloat y =  maxH - (MAX(m.Open, m.Close) - minMaxModel.min) * unitValue;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w - config.kLineGap, h) cornerRadius:config.kCandleRadius];

            // YYKlineModel 赋值
            m.mainCenterPoint = lowPoint;
            CGFloat candleCenterY = maxH - (m.Close - minMaxModel.min) * unitValue;
            m.candleCrossLineCenterPoint = CGPointMake(centerX+CGRectGetMinX(area), candleCenterY);

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
        }
    }];
    [layer addSublayer:sublayer];
}


+ (YYKlineModel *)getKlineModel:(CGPoint)touchPoint
                           area:(CGRect)area
                    styleConfig:(YYKlineStyleConfig *)config
                         models:(NSArray<YYKlineModel *> *)models {
    CGFloat locationX = touchPoint.x - CGRectGetMinX(area);
    NSInteger idx = ABS(floor(locationX / (config.kLineWidth + config.kLineGap)));
    idx = MIN(idx, models.count - 1);
    return [models objectAtIndex:idx];
}
@end
