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
    CGFloat minAssert = data.Low;
    CGFloat maxAssert = data.High;
    return [YYMinMaxModel modelWithMin:minAssert max:maxAssert];
}

+ (void)drawToLayer:(CALayer *)layer
              point:(CGPoint)point
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
           leftText:(NSAttributedString * _Nullable)leftText
          rightText:(NSAttributedString * _Nullable)rightText
           downText:(NSAttributedString * _Nullable)downText {
    CGFloat maxW = CGRectGetWidth(area);
    CGFloat maxH = CGRectGetHeight(area);

    YYCrossLinePainter *sublayer = [[YYCrossLinePainter alloc] init];
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
        UIBezierPath *outerCirclePath = [UIBezierPath bezierPathWithArcCenter:point radius:config.kLineCrossCenterRadius startAngle:0 endAngle:2*M_PI clockwise:YES];


        CAShapeLayer *container = [CAShapeLayer layer];
        container.path = outerCirclePath.CGPath;
        container.lineWidth = config.kLineCrossCenterRadius/2;
        container.strokeColor = UIColor.clearColor.CGColor;
        container.fillColor = UIColor.clearColor.CGColor;
        [sublayer addSublayer:container];

        // 添加阴影
        CAShapeLayer *shadow = [CAShapeLayer layer];
        shadow.shadowColor = config.crossLineCenterShadowColor.CGColor;
        shadow.shadowRadius = config.kLineCrossCenterRadius;
        shadow.shadowOpacity = 1.0;
        shadow.shadowPath = outerCirclePath.CGPath;
        shadow.shadowOffset = CGSizeZero;
        [container addSublayer:shadow];

        // 添加中心点
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = outerCirclePath.CGPath;
        l.lineWidth = config.kLineCrossCenterRadius/2;
        l.strokeColor = UIColor.whiteColor.CGColor;
        l.fillColor = config.crossLineCenterColor.CGColor;
        [container addSublayer:l];
    }

    // 画 horizontal left text
    if (leftText){
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = leftText;
        textLayer.wrapped = YES;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.backgroundColor = config.crossLineTextBackgroundColor.CGColor;

        // 计算文字frame
        CGRect rect = [leftText boundingRectWithSize:CGSizeMake(config.kLineCrossTextMaxWidth, config.kLineCrossTextHeight) options:NSStringDrawingUsesFontLeading context:nil];
        CGFloat y = MAX(0, point.y-config.kLineCrossTextHeight/2);
        textLayer.frame = CGRectMake(0, y, rect.size.width+config.kLineCrossTextInset.left+config.kLineCrossTextInset.right, config.kLineCrossTextHeight);

        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
        
    }

    // 画 horizontal right text
    if (rightText){
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = rightText;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.backgroundColor = config.crossLineTextBackgroundColor.CGColor;
        // 计算文字frame
        CGRect rect = [rightText boundingRectWithSize:CGSizeMake(config.kLineCrossTextMaxWidth, config.kLineCrossTextHeight) options:NSStringDrawingUsesFontLeading context:nil];
        CGFloat width = rect.size.width+config.kLineCrossTextInset.left+config.kLineCrossTextInset.right;
        CGFloat y = MAX(0, point.y-config.kLineCrossTextHeight/2);
        textLayer.frame = CGRectMake(maxW-width, y, width, config.kLineCrossTextHeight);

        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
    }

    // 画 down text
    if (downText){
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = downText;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.backgroundColor = config.crossLineTextBackgroundColor.CGColor;
        // 计算文字frame
        CGRect rect = [downText boundingRectWithSize:CGSizeMake(config.kLineCrossTextMaxWidth, config.kLineCrossTextHeight) options:NSStringDrawingUsesFontLeading context:nil];
        CGFloat width = rect.size.width+config.kLineCrossTextInset.left+config.kLineCrossTextInset.right;
        CGFloat x = MAX(0, point.x-width/2);
        x = MIN(x, area.size.width-width);
        textLayer.frame = CGRectMake(x, CGRectGetMaxY(area)-config.kLineCrossTextHeight, width, config.kLineCrossTextHeight);

        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
    }

    [layer addSublayer:sublayer];
}

@end
