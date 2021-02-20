//
//  YYCrossPainter.m
//  YYKline
//
//  Created by aqumon on 2021/2/19.
//  Copyright © 2021 WillkYang. All rights reserved.
//

#import "YYCrossPainter.h"
#import "YYKlineGlobalVariable.h"
#import "UIColor+YYKline.h"

@implementation YYCrossPainter

+ (void)drawToLayer:(CALayer *)layer point:(CGPoint)point area:(CGRect)area models:(NSArray<YYKlineModel *> *)models idx:(NSUInteger)idx leftText:(NSAttributedString *)leftText rightText:(NSAttributedString *)rightText{
    if(!models) {
        return;
    }
    CGFloat maxW = CGRectGetWidth(area);
    CGFloat maxH = CGRectGetHeight(area);

    YYCrossPainter *sublayer = [[YYCrossPainter alloc] init];
    sublayer.frame = area;

//    CGFloat w = [YYKlineGlobalVariable kLineWidth];
//    CGFloat x = idx * (w + [YYKlineGlobalVariable kLineGap]);
//    CGFloat centerX = x+w/2.f-[YYKlineGlobalVariable kLineGap]/2.f;

    // 画 vertical line
    {
        UIBezierPath *verticalPath = [UIBezierPath bezierPath];
        [verticalPath moveToPoint:CGPointMake(point.x, 0)];
        [verticalPath addLineToPoint:CGPointMake(point.x, maxH)];

        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = verticalPath.CGPath;
        l.lineWidth = YYKlineLineWidth/[UIScreen mainScreen].scale;
        l.strokeColor = UIColor.timeLineLineColor.CGColor;
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
        l.lineWidth = YYKlineLineWidth/[UIScreen mainScreen].scale;
        l.strokeColor = UIColor.timeLineLineColor.CGColor;
        l.fillColor =   [UIColor clearColor].CGColor;
        [sublayer addSublayer:l];
    }

    // 画中点
    {
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        [circlePath addArcWithCenter:point radius:4.0 startAngle:0 endAngle:2*M_PI clockwise:YES];

        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = circlePath.CGPath;
        //        l.lineWidth = YYKlineLineWidth/[UIScreen mainScreen].scale;
        l.strokeColor = UIColor.redColor.CGColor;
        l.fillColor =   [UIColor redColor].CGColor;
        [sublayer addSublayer:l];
    }

    // 画 horizontal left text
    {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = leftText;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = 12.f;
        textLayer.foregroundColor = UIColor.whiteColor.CGColor;
        textLayer.backgroundColor = UIColor.grayColor.CGColor;
        textLayer.frame = CGRectMake(20, point.y-10, 100, 20);
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
        
    }

    // 画 horizontal right text
    {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = rightText;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = 12.f;
        textLayer.foregroundColor = UIColor.whiteColor.CGColor;
        textLayer.backgroundColor = UIColor.grayColor.CGColor;
        textLayer.frame = CGRectMake(maxW-50-20, point.y-10, 100, 20);
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
    }

    [layer addSublayer:sublayer];
}

@end
