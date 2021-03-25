//
//  YYTimePainter.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYTimePainter.h"
#import "YYKlineStyleConfig.h"

@implementation YYTimePainter

/**
 * Aqumon K线图规则：
 * 横轴：时间，展示五个时间标签，标签值为起始时间点和三个四等分点；
 格式为分时图：HH:MM（数字格式）;
 五日，日K，周K，月K：MM-DD（数字格式）；年K：YY-MM（数字格式）。
 */
+ (void)drawToLayer:(CALayer *)layer
               area:(CGRect)area
        styleConfig:(YYKlineStyleConfig *)config
         timestamps:(NSArray<NSString *> *)timestamps {
    CGFloat maxH = CGRectGetHeight(area);
    if (maxH <= 0) {
        return;
    }

    YYTimePainter *sublayer = [[YYTimePainter alloc] init];
    sublayer.backgroundColor = config.assistBackgroundColor.CGColor;
    sublayer.frame = area;
    [layer addSublayer:sublayer];

    // 等分
    NSInteger gap = (area.size.width/(timestamps.count-1));
    [timestamps enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect textBounds = [obj boundingRectWithSize:CGSizeMake(100, maxH) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:config.timelineFont} context:nil];

        CGFloat x = idx * gap;
        CGFloat y = (maxH - config.timelineFont.lineHeight)/2.f;
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = obj;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.font = (__bridge CFTypeRef _Nullable)(config.timelineFontName);
        textLayer.fontSize = config.timelineFont.pointSize;
        textLayer.foregroundColor = config.timeLineColor.CGColor;

        CGFloat originX = x-textBounds.size.width/2;
        originX = MAX(0, originX);
        originX = MIN(originX, area.size.width-textBounds.size.width);
        textLayer.frame = CGRectMake(originX, y, textBounds.size.width, textBounds.size.height);
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
    }];
}

//+ (void)drawToLayer:(CALayer *)layer
//               area:(CGRect)area
//        styleConfig:(YYKlineStyleConfig *)config
//             models:(NSArray <YYKlineModel *> *)models
//             minMax: (YYMinMaxModel *)minMaxModel {
//    CGFloat maxH = CGRectGetHeight(area);
//    if (maxH <= 0) {
//        return;
//    }
//
//    YYTimePainter *sublayer = [[YYTimePainter alloc] init];
//    sublayer.backgroundColor = config.assistBackgroundColor.CGColor;
//    sublayer.frame = area;
//    [layer addSublayer:sublayer];
//
//    /**
//     * 时间绘制规则 展示五个时间标签，标签值为起始时间点和三个四等分点；
//     */
//    NSInteger gap = (area.size.width/4) / (config.kLineWidth + config.kLineGap);
//
//    models.firstObject.isDrawTime = YES;
//    models.lastObject.isDrawTime = YES;
//    for (int i = 1; i < models.count - 1; i++) {
//        models[i].isDrawTime = i % gap == 0;
//    }
//
//    CGFloat w = config.kLineWidth;
//    [models enumerateObjectsUsingBlock:^(YYKlineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (!obj.isDrawTime) {
//            return;
//        }
//        CGRect textBounds = [obj.drawTime boundingRectWithSize:CGSizeMake(100, maxH) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:config.timelineFont} context:nil];
//
//        CGFloat x = idx * (w + config.kLineGap);
//        CGFloat y = (maxH - config.timelineFont.lineHeight)/2.f;
//        CATextLayer *textLayer = [CATextLayer layer];
//        textLayer.string = obj.drawTime;
//        textLayer.alignmentMode = kCAAlignmentCenter;
//        textLayer.font = (__bridge CFTypeRef _Nullable)(config.timelineFontName);
//        textLayer.fontSize = config.timelineFont.pointSize;
//        textLayer.foregroundColor = config.timeLineColor.CGColor;
//
//        CGFloat originX = x-textBounds.size.width/2;
//        originX = MAX(0, originX);
//        originX = MIN(originX, area.size.width-textBounds.size.width);
//        textLayer.frame = CGRectMake(originX, y, textBounds.size.width, textBounds.size.height);
//        textLayer.contentsScale = UIScreen.mainScreen.scale;
//        [sublayer addSublayer:textLayer];
//    }];
//}

@end
