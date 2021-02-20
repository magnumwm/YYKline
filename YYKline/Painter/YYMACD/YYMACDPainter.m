//
//  YYMACDPainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYMACDPainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYMACDPainter
+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
    __block CGFloat maxAssert = 0.f;
    [data enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        maxAssert = MAX(maxAssert, MAX(fabsf(m.MACD.DIFF.floatValue), MAX(fabsf(m.MACD.DEA.floatValue), fabsf(m.MACD.MACD.floatValue))));
    }];
    return [YYMinMaxModel modelWithMin:-maxAssert max:maxAssert];
}

+ (void)drawToLayer:(CALayer *)layer area:(CGRect)area models:(NSArray <YYKlineModel *> *)models minMax: (YYMinMaxModel *)minMaxModel {
    if(!models) {
        return;
    }
    CGFloat maxH = CGRectGetHeight(area);
    CGFloat unitValue = maxH/minMaxModel.distance;
    
    YYMACDPainter *sublayer = [[YYMACDPainter alloc] init];
    YYKlineStyleConfig *config = YYKlineStyleConfig.config;
    sublayer.frame = area;
    [layer addSublayer:sublayer];
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat w = config.kLineWidth;
        CGFloat x = idx * (w + config.kLineGap);
        // 开收
        CGFloat h = fabsf(m.MACD.MACD.floatValue) * unitValue;
        CGFloat y = 0.f;
        if (m.MACD.MACD.floatValue > 0) {
            y = maxH - h + minMaxModel.min * unitValue;
        } else {
            y = maxH + minMaxModel.min * unitValue;
        }
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w - config.kLineGap, h)];
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = path.CGPath;
        l.lineWidth = config.kLineLineWidth;
        
        l.strokeColor = m.MACD.MACD.floatValue < 0 ? config.upColor.CGColor : config.downColor.CGColor;
        l.fillColor =   m.MACD.MACD.floatValue < 0 ? config.upColor.CGColor : config.downColor.CGColor;
        [sublayer addSublayer:l];
        
        
        CGPoint point1 = CGPointMake(x+w/2, maxH - (m.MACD.DEA.floatValue - minMaxModel.min)*unitValue);
        CGPoint point2 = CGPointMake(x+w/2, maxH - (m.MACD.DIFF.floatValue - minMaxModel.min)*unitValue);
        if (idx == 0) {
            [path1 moveToPoint:point1];
            [path2 moveToPoint:point2];
        } else {
            [path1 addLineToPoint:point1];
            [path2 addLineToPoint:point2];
        }
    }];
    
    {
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = path1.CGPath;
        l.lineWidth = config.kLineLineWidth;
        l.strokeColor = config.line1Color.CGColor;
        l.fillColor =   [UIColor clearColor].CGColor;
        [sublayer addSublayer:l];
    }
    {
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = path2.CGPath;
        l.lineWidth = config.kLineLineWidth;
        l.strokeColor = config.line2Color.CGColor;
        l.fillColor =   [UIColor clearColor].CGColor;
        [sublayer addSublayer:l];
    }
}

+ (NSAttributedString *)getText:(YYKlineModel *)model {
    return model.V_MACD;
}
@end
