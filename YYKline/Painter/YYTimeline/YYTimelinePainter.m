//
//  YYTimelinePainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYTimelinePainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYTimelinePainter

+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
    __block CGFloat minAssert = 999999999999.f;
    __block CGFloat maxAssert = 0.f;
    [data enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        maxAssert = MAX(maxAssert, m.Close.floatValue);
        minAssert = MIN(minAssert, m.Close.floatValue);
    }];
    return [YYMinMaxModel modelWithMin:minAssert max:maxAssert];
}

+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
              total:(NSInteger)total
             models:(NSArray<YYKlineModel*> *)models
             minMax:(YYMinMaxModel *)minMaxModel {
    if(!models || models.count == 0) {
        return;
    }

    CGFloat maxW = CGRectGetWidth(area);
    CGFloat maxH = CGRectGetHeight(area);
    CGFloat gap = maxW/total;

    CGFloat unitValue = maxH/minMaxModel.distance;

    __block CGPoint pointStart, pointEnd;
    YYTimelinePainter *sublayer = [[YYTimelinePainter alloc] init];
    sublayer.frame = area;
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat w = config.kLineWidth;
        CGFloat x = idx * gap;
        CGPoint point1 = CGPointMake(x+w/2, maxH - (m.Close.floatValue - minMaxModel.min)*unitValue);
        if (idx == 0) {
            [path1 moveToPoint:point1];
            pointStart = point1;
        } else {
            [path1 addLineToPoint:point1];
        }
        m.timelineCrossLineCenterPoint = CGPointMake(point1.x+CGRectGetMinX(area), point1.y);
        if (idx == models.count - 1) {
            pointEnd = point1;
        }
    }];

    // 画线
    {
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = path1.CGPath;
        l.lineWidth = config.kTimelineLineWidth;
        l.strokeColor = config.timeLineLineColor.CGColor;
        l.fillColor =   [UIColor clearColor].CGColor;
        [sublayer addSublayer:l];
    }
    [layer addSublayer:sublayer];

    // 渐变背景色
    {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIBezierPath *path2 = [path1 copy];
        [path2 addLineToPoint:CGPointMake(pointEnd.x, maxH)];
        [path2 addLineToPoint: CGPointMake(pointStart.x, maxH)];
        [path2 closePath];
        maskLayer.path = path2.CGPath;
        CAGradientLayer *bgLayer = [CAGradientLayer layer];
        bgLayer.frame = area;
        bgLayer.colors = @[(id)config.timelineGradientStartColor.CGColor, (id)config.timelineGradientEndColor.CGColor];
        //        bgLayer.locations = @[@0.3, @0.9];
        bgLayer.mask = maskLayer;
        [layer addSublayer:bgLayer];
    }
}

/// 获取触摸点对应的KlineModel
+ (YYKlineModel *)getKlineModel:(CGPoint)touchPoint
                           area:(CGRect)area
                          total:(NSInteger)total
                         models:(NSArray<YYKlineModel*> *)models {
    CGFloat maxW = CGRectGetWidth(area);
    CGFloat gap = maxW/total;
    NSInteger idx = (touchPoint.x - CGRectGetMinX(area)) / gap;
    return [models objectAtIndex:idx%models.count];
}

@end
