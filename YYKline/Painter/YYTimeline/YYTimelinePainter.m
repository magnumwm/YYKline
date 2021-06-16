//
//  YYTimelinePainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYTimelinePainter.h"
#import "YYKlineStyleConfig.h"
#import "YYTimePainter.h"
#import "YYKlineRootModel.h"

@implementation YYTimelinePainter

+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
    __block CGFloat minAssert = 999999999999.f;
    __block CGFloat maxAssert = 0.f;
    [data enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        if (m.Close > 0) {
            maxAssert = MAX(maxAssert, m.Close);
            minAssert = MIN(minAssert, m.Close);
        }
    }];
    return [YYMinMaxModel modelWithMin:minAssert max:maxAssert];
}

+ (void)drawToLayer:(CALayer *)layer
          timeLayer:(CALayer *)timeLayer
        styleConfig:(YYKlineStyleConfig *)config
              total:(NSInteger)total
             models:(NSArray<YYKlineModel*> *)models
             minMax:(YYMinMaxModel *)minMaxModel
        drawFiveDay:(BOOL)isFiveDayTime{
    if(!models || models.count == 0) {
        return;
    }

    CGFloat maxW = CGRectGetWidth(layer.frame);
    CGFloat maxH = CGRectGetHeight(layer.frame);
    CGFloat minX = CGRectGetMinX(layer.frame);
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
    NSUInteger startIndex = 0;
    for (YYKlineModel *model in models) {
        if (model.Close > 0) {
            break;
        }
        startIndex++;
    }
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            CGFloat x = idx * gap;
            CGPoint point1 = CGPointMake(x, maxH - (m.Close - minMaxModel.min)*unitValue);
            m.mainCenterPoint = point1;
            m.timelineCrossLineCenterPoint = CGPointMake(point1.x+minX, point1.y);
            if (idx == 0) {
                // 第一个时间点的时间string
                NSDateFormatter *formatter = config.timestampFormatter;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:m.Timestamp];
                lastTimeStr = [formatter stringFromDate:date];

                // 绘制第一个时间点
                if (isFiveDayTime) {
                    [YYTimePainter drawToLayer:timeSubLayer styleConfig:config model:m];
                } else {
                    // 今日分时绘制MMDD日期，时间戳不是今天才需要绘制
                    if (![formatter.calendar isDateInToday:date]) {
                        [YYTimePainter drawToLayer:timeSubLayer styleConfig:config model:m text:m.V_Date];
                    }
                }
            }

            if (idx == startIndex) {
                pointStart = point1;
            }

            if (m.Close > 0) {
                if (idx == startIndex) {
                    [path1 moveToPoint:point1];
                } else {
                    [path1 addLineToPoint:point1];
                }
                pointEnd = point1;
            }
            
            NSDateFormatter *formatter = config.timestampFormatter;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:m.Timestamp];
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
                NSArray *timeArray;
                NSString *drawText;
                if (models.count <= kChinaStockTimeFramesMaxCount) {
                    timeArray = @[@"10:00", @"11:30", @"15:00"];
                } else {
                    timeArray = @[@"10:00", @"11:59", @"16:00"];
                }

                for (NSString *keyTime in timeArray) {
                    if ([keyTime isEqualToString:currentTimeStr]) {
                        drawText = keyTime;
                        if ([keyTime isEqualToString:@"11:59"]) {
                            drawText = @"12:00";
                        }
                        [YYTimePainter drawToLayer:timeSubLayer styleConfig:config model:m text:drawText];
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
    if (idx < models.count) {
        YYKlineModel *model = [models objectAtIndex:idx];
        if (model.Close == kStockPriceNullValue) {
            // 数据为空的情况，先往后遍历搜索到有数据的点
            NSInteger index = idx+1;
            while (index < models.count) {
                model = [models objectAtIndex:index];
                if (model.Close > kStockPriceNullValue) {
                    return model;
                }
                index++;
            }
            // 先往前遍历搜索到有数据的点
            index = idx-1;
            while (index >= 0) {
                model = [models objectAtIndex:index];
                if (model.Close > kStockPriceNullValue) {
                    return model;
                }
                index--;
            }
        }
        return model;
    } else {
        return nil;
    }
}

@end
