//
//  YYVolPainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYVolPainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYVolPainter
+ (YYMinMaxModel *)getMinMaxValue:(NSArray <YYKlineModel *> *)data {
    if(!data) {
        return [YYMinMaxModel new];
    }
    __block CGFloat minAssert = 0.f;
    __block CGFloat maxAssert = 0.f;
    [data enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        maxAssert = MAX(maxAssert, m.Volume.floatValue);
    }];
    return [YYMinMaxModel modelWithMin:minAssert max:maxAssert];
}

+ (void)drawToLayer:(CALayer *)layer area:(CGRect)area models:(NSArray <YYKlineModel *> *)models minMax: (YYMinMaxModel *)minMaxModel {
    if(!models) {
        return;
    }
    CGFloat maxH = CGRectGetHeight(area);
    CGFloat unitValue = maxH/minMaxModel.distance;

    YYVolPainter *sublayer = [[YYVolPainter alloc] init];
    YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
    sublayer.frame = area;
    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat w = config.kLineWidth;
        CGFloat x = idx * (w + config.kLineGap);
        CGFloat h = fabs(m.Volume.floatValue - minMaxModel.min) * unitValue;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, maxH - h, w - config.kLineGap, h) cornerRadius:config.kVolumeBarRadius];
        CAShapeLayer *l = [CAShapeLayer layer];
        l.path = path.CGPath;
//        l.lineWidth = config.kLineLineWidth;
//        l.strokeColor = m.isUp ? config.volumeUpColor.CGColor : config.volumeDownColor.CGColor;
        l.fillColor = m.isUp ? config.volumeUpColor.CGColor : config.volumeDownColor.CGColor;
        [sublayer addSublayer:l];
    }];
    [layer addSublayer:sublayer];
}
@end
