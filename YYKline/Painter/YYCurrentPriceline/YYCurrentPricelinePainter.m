//
//  YYCurrentPricelinePainter.m
//  YYKline
//
//  Created by aqumon on 2021/3/22.
//

#import "YYCurrentPricelinePainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYCurrentPricelinePainter
+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
             models:(NSArray <YYKlineModel *> *)models
             minMax: (YYMinMaxModel *)minMaxModel
            current:(CGFloat)price {
    if(!models) {
        return;
    }

    CGFloat maxH = CGRectGetHeight(area);
    CGFloat unitValue = maxH/minMaxModel.distance;

    // 计算当前价格所在位置
    CGFloat originY = (minMaxModel.max - price) * unitValue + CGRectGetMinY(area);

    CGPoint pointStart = CGPointMake(0, originY);
    CGPoint pointEnd = CGPointMake(CGRectGetMaxX(area), originY+1);
    YYCurrentPricelinePainter *sublayer = [[YYCurrentPricelinePainter alloc] init];
    sublayer.frame = area;
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:pointStart];
    [path1 addLineToPoint:pointEnd];
    // 画线
    {
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = path1.CGPath;
        l.lineWidth = config.kTimelineLineWidth;
        l.strokeColor = config.crossLineColor.CGColor;
        l.lineDashPhase = 1;
        l.lineDashPattern = @[@2,@3];
        l.fillColor = config.crossLineColor.CGColor;
        [sublayer addSublayer:l];
    }
    [layer addSublayer:sublayer];
}
@end
