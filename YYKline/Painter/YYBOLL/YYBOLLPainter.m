//
//  YYBOLLPainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYBOLLPainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYBOLLPainter

+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
    __block CGFloat minAssert = 999999999999.f;
    __block CGFloat maxAssert = 0.f;
    [data enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        maxAssert = MAX(maxAssert, MAX(m.BOLL.LOW.floatValue, MAX(m.BOLL.UP.floatValue, m.BOLL.MID.floatValue)));
        minAssert = MIN(minAssert, MIN(m.BOLL.LOW.floatValue, MIN(m.BOLL.UP.floatValue, m.BOLL.MID.floatValue)));
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
    
    YYBOLLPainter *sublayer = [[YYBOLLPainter alloc] init];
    sublayer.frame = area;
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    UIBezierPath *path3 = [UIBezierPath bezierPath];
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat w = config.kLineWidth;
        CGFloat x = idx * (w + config.kLineGap);
        CGPoint point1 = CGPointMake(x+w/2, maxH - (m.BOLL.UP.floatValue - minMaxModel.min)*unitValue);
        CGPoint point2 = CGPointMake(x+w/2, maxH - (m.BOLL.MID.floatValue - minMaxModel.min)*unitValue);
        CGPoint point3 = CGPointMake(x+w/2, maxH - (m.BOLL.LOW.floatValue - minMaxModel.min)*unitValue);
        if (idx == 0) {
            [path1 moveToPoint:point1];
            [path2 moveToPoint:point2];
            [path3 moveToPoint:point3];
        } else {
            [path1 addLineToPoint:point1];
            [path2 addLineToPoint:point2];
            [path3 addLineToPoint:point3];
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
    {
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = path3.CGPath;
        l.lineWidth = config.kLineLineWidth;
        l.strokeColor = config.line3Color.CGColor;
        l.fillColor =   [UIColor clearColor].CGColor;
        [sublayer addSublayer:l];
    }
    [layer addSublayer:sublayer];
}

+ (NSAttributedString *)getText:(YYKlineModel *)model {
    return model.V_BOLL;
}

@end
