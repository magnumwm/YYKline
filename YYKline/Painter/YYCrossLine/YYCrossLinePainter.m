//
//  YYCrossPainter.m
//  YYKline
//
//  Created by aqumon on 2021/2/19.
//  Copyright © 2021 WillkYang. All rights reserved.
//

#import "YYCrossLinePainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYCrossLinePainter

+ (YYMinMaxModel *)getMinMaxValue:(YYKlineModel *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
    CGFloat minAssert = data.Low.floatValue;
    CGFloat maxAssert = data.High.floatValue;
    return [YYMinMaxModel modelWithMin:minAssert max:maxAssert];
}

+ (void)drawToLayer:(CALayer *)layer
              point:(CGPoint)point
               area:(CGRect)area
           leftText:(NSAttributedString *)leftText
          rightText:(NSAttributedString *)rightText{
    CGFloat maxW = CGRectGetWidth(area);
    CGFloat maxH = CGRectGetHeight(area);

    YYCrossLinePainter *sublayer = [[YYCrossLinePainter alloc] init];
    YYKlineStyleConfig *config = YYKlineStyleConfig.config;
    sublayer.frame = area;

    // 画 vertical line
    {
        UIBezierPath *verticalPath = [UIBezierPath bezierPath];
        [verticalPath moveToPoint:CGPointMake(point.x, 0)];
        [verticalPath addLineToPoint:CGPointMake(point.x, maxH)];

        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = verticalPath.CGPath;
        l.lineWidth = config.kLineCrosslineWidth;
        l.strokeColor = config.crossLineColor.CGColor;
        l.fillColor =   [UIColor clearColor].CGColor;
        [sublayer addSublayer:l];
    }

    // 画 horizontal line
    {
        UIBezierPath *horizontalPath = [UIBezierPath bezierPath];
        [horizontalPath moveToPoint:CGPointMake(0, point.y)];
        [horizontalPath addLineToPoint:CGPointMake(maxW, point.y)];

        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = horizontalPath.CGPath;
        l.lineWidth = config.kLineCrosslineWidth;
        l.strokeColor = config.crossLineColor.CGColor;
        l.fillColor =   [UIColor clearColor].CGColor;
        [sublayer addSublayer:l];
    }

    // 画中点
    {
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        [circlePath addArcWithCenter:point radius:config.kLineCrossCenterRadius startAngle:0 endAngle:2*M_PI clockwise:YES];

        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = circlePath.CGPath;
//        l.lineWidth = config.kLineCrossCenterRadius;
//        l.strokeColor = UIColor.whiteColor.CGColor;
//        l.shadowRadius = 4;
//        l.shadowColor = [UIColor.redColor colorWithAlphaComponent:0.6].CGColor;
        l.fillColor =   config.crossLineCenterColor.CGColor;
        [sublayer addSublayer:l];
    }

    // 画 horizontal left text
    {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = leftText;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = config.crosslineLabelFont.pointSize;
        textLayer.foregroundColor = config.crossLineLabelColor.CGColor;
        textLayer.backgroundColor = config.crossLineLabelBackgroundColor.CGColor;
        textLayer.frame = CGRectMake(20, point.y-10, 100, 20);
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
        
    }

    // 画 horizontal right text
    {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = rightText;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = config.crosslineLabelFont.pointSize;
        textLayer.foregroundColor = config.crossLineLabelColor.CGColor;
        textLayer.backgroundColor = config.crossLineLabelBackgroundColor.CGColor;
        textLayer.frame = CGRectMake(maxW-50-20, point.y-10, 100, 20);
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
    }

    [layer addSublayer:sublayer];
}

@end
