//
//  YYTimelinePainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYTimelinePainter.h"
#import "YYKlineStyleConfig.h"
#import "YYTimePainter.h"

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
    // 创建分时图Layer
    YYTimelinePainter *sublayer = [[YYTimelinePainter alloc] init];
    sublayer.frame = area;
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = idx * gap;
        CGPoint point1 = CGPointMake(x, maxH - (m.Close.floatValue - minMaxModel.min)*unitValue);
        if (idx == 0) {
            [path1 moveToPoint:point1];
            pointStart = point1;
        } else {
            [path1 addLineToPoint:point1];
        }
        m.mainCenterPoint = point1;
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

+ (void)drawToLayer:(CALayer *)layer
          timeLayer:(CALayer *)timeLayer
        styleConfig:(YYKlineStyleConfig *)config
              total:(NSInteger)total
             models:(NSArray<YYKlineModel*> *)models
             minMax:(YYMinMaxModel *)minMaxModel {
    if(!models || models.count == 0) {
        return;
    }

    /**
     * 根据数据点数量判断是否绘制今日分时图还是五日分时图，一天一般9:30am-4pm 的每分钟的数据量 = (16 - 9.5 - 1) = 5.5 * 60 = 330 左右 数据点
     */
    BOOL isFiveDayTime = models.count > 400;

    CGFloat maxW = CGRectGetWidth(layer.bounds);
    CGFloat maxH = CGRectGetHeight(layer.bounds);
    CGFloat gap = maxW/total;

    CGFloat unitValue = maxH/minMaxModel.distance;

    __block CGPoint pointStart, pointEnd;
    __block NSString *lastTimeStr;

    // 创建时间轴Layer
    [timeLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    YYTimePainter *timeSubLayer = [[YYTimePainter alloc] init];
    timeSubLayer.backgroundColor = config.assistBackgroundColor.CGColor;
    timeSubLayer.frame = timeLayer.bounds;
    [timeLayer addSublayer:timeSubLayer];

    // 创建分时图Layer
    YYTimelinePainter *sublayer = [[YYTimelinePainter alloc] init];
    sublayer.frame = layer.bounds;
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            CGFloat x = idx * gap;
            CGPoint point1 = CGPointMake(x, maxH - (m.Close.floatValue - minMaxModel.min)*unitValue);
            m.mainCenterPoint = point1;
            m.timelineCrossLineCenterPoint = CGPointMake(point1.x+CGRectGetMinX(layer.bounds), point1.y);

            if (idx == 0) {
                // 第一个时间点的时间string
                NSDateFormatter *formatter = config.timestampFormatter;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:m.Timestamp.doubleValue];
                lastTimeStr = [formatter stringFromDate:date];

                // 绘制第一个时间点
                if (isFiveDayTime) {
                    [YYTimePainter drawToLayer:timeSubLayer styleConfig:config model:m];
                } else {
                    // 今日分时绘制MMDD日期
                    [YYTimePainter drawToLayer:timeSubLayer styleConfig:config model:m text:m.V_Date];
                }


                [path1 moveToPoint:point1];
                pointStart = point1;
            } else {
                [path1 addLineToPoint:point1];
            }
            if (idx == models.count - 1) {
                pointEnd = point1;
            }

            NSDateFormatter *formatter = config.timestampFormatter;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:m.Timestamp.doubleValue];
            NSString *currentTimeStr = [formatter stringFromDate:date];
            // 绘制关键时间点
            if (isFiveDayTime) {
                /**
                 * 五日时间点以MM-DD分隔 每个日期第一个数据点的位置
                 */
                if (![currentTimeStr isEqualToString:lastTimeStr]) {
                    // 绘制新的时间点
                    [YYTimePainter drawToLayer:timeSubLayer styleConfig:config model:m];
                    lastTimeStr = currentTimeStr;
                }
            } else {
                /**
                 * 当日分时时间点以HH:mm分隔 时间点开始时间点，午休时间段，闭市时间点,
                 * 以10am为起点 每隔一个小时绘制一次；需要找出午休时间开始和结束的时间点
                 */
                NSArray *timeArray = @[@"10:00", @"11:00", @"12:00", @"13:00", @"14:00", @"15:00", @"16:00"];
                for (NSString *keyTime in timeArray) {
                    if ([keyTime isEqualToString:currentTimeStr]) {
                        [YYTimePainter drawToLayer:timeSubLayer styleConfig:config model:m];
                    }
                }
            }
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
        bgLayer.frame = layer.bounds;
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
    if (idx < models.count ) {
        return [models objectAtIndex:idx];
    } else {
        return nil;
    }
}

@end
