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
         timestamps:(NSArray *)timestamps
             layout:(YYXAxisTimeTextLayout)layout {
    CGFloat maxH = CGRectGetHeight(area);
    if (maxH <= 0) {
        return;
    }

    YYTimePainter *sublayer = [[YYTimePainter alloc] init];
    sublayer.backgroundColor = config.assistBackgroundColor.CGColor;
    sublayer.frame = area;
    [layer addSublayer:sublayer];

    // YYXAxisTimeTextLayoutEqualBetween
    CGFloat gap = 0.0;
    switch (layout) {
        case YYXAxisTimeTextLayoutEqualBetween:
            gap = (area.size.width/((timestamps.count-1)*1.0));
            break;
        case YYXAxisTimeTextLayoutEqualCenter:
            gap = (area.size.width/(timestamps.count * 1.0));
            break;
        case YYXAxisTimeTextLayoutEqualStart:
            gap = (area.size.width/(timestamps.count*1.0));
            break;
        default:
            break;
    }
    [timestamps enumerateObjectsUsingBlock:^(NSObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *text;
        if ([obj isKindOfClass:YYKlineModel.class]) {
            NSDateFormatter *formatter = config.timestampFormatter;
            YYKlineModel *model = (YYKlineModel *)obj;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.Timestamp];
            text = [formatter stringFromDate:date];
        } else {
            text = (NSString *)obj;
        }
        CGRect textBounds = [text boundingRectWithSize:CGSizeMake(100, maxH) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:config.timelineFont} context:nil];

        CGFloat y = (maxH - config.timelineFont.lineHeight)/2.f;
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = text;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.font = (__bridge CFTypeRef _Nullable)(config.timelineFontName);
        textLayer.fontSize = config.timelineFont.pointSize;
        textLayer.foregroundColor = config.timeLineColor.CGColor;

//        CGFloat originX = x-textBounds.size.width/2;
        CGFloat originX = 0;
        switch (layout) {
            case YYXAxisTimeTextLayoutEqualBetween:
                originX = idx * gap;
                break;
            case YYXAxisTimeTextLayoutEqualCenter:
                originX = idx * gap + (gap - textBounds.size.width)/2.f;
                break;
            case YYXAxisTimeTextLayoutEqualStart:
                originX = idx * gap;
                break;
            case YYXAxisTimeTextLayoutEqualToMainPoint: {
                YYKlineModel *model = (YYKlineModel *)obj;
                originX = model.mainCenterPoint.x - textBounds.size.width/2.f;
                break;
            }
            default:
                break;
        }
        originX = MAX(0, originX);
        originX = MIN(originX, area.size.width-textBounds.size.width);
        textLayer.frame = CGRectMake(originX, y, textBounds.size.width, textBounds.size.height);
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [sublayer addSublayer:textLayer];
    }];
}

+ (void)drawToLayer:(CALayer *)layer
        styleConfig:(YYKlineStyleConfig *)config
              model:(YYKlineModel *)model {
    CGFloat maxH = CGRectGetHeight(layer.bounds);
    if (maxH <= 0) {
        return;
    }

    NSDateFormatter *formatter = config.timestampFormatter;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.Timestamp];

    NSString *text = [formatter stringFromDate:date];
    CGRect textBounds = [text boundingRectWithSize:CGSizeMake(100, maxH) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:config.timelineFont} context:nil];

    CGFloat y = (maxH - config.timelineFont.lineHeight)/2.f;
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.font = (__bridge CFTypeRef _Nullable)(config.timelineFontName);
    textLayer.fontSize = config.timelineFont.pointSize;
    textLayer.foregroundColor = config.timeLineColor.CGColor;

    CGFloat originX = MAX(0, model.mainCenterPoint.x);
    originX = MIN(originX, layer.bounds.size.width-textBounds.size.width);
    textLayer.frame = CGRectMake(originX, y, textBounds.size.width, textBounds.size.height);
    textLayer.contentsScale = UIScreen.mainScreen.scale;
    [layer addSublayer:textLayer];
}

/// 绘制单个时间点
/// @param layer 时间轴layer
/// @param config YYKlineStyleConfig
/// @param text 绘制的文字
+ (void)drawToLayer:(CALayer *)layer
        styleConfig:(YYKlineStyleConfig *)config
              model:(YYKlineModel *)model
               text:(NSString *)text {
    CGFloat maxH = CGRectGetHeight(layer.bounds);
    if (maxH <= 0) {
        return;
    }

    CGRect textBounds = [text boundingRectWithSize:CGSizeMake(100, maxH) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:config.timelineFont} context:nil];

    CGFloat y = (maxH - config.timelineFont.lineHeight)/2.f;
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.font = (__bridge CFTypeRef _Nullable)(config.timelineFontName);
    textLayer.fontSize = config.timelineFont.pointSize;
    textLayer.foregroundColor = config.timeLineColor.CGColor;

    CGFloat originX = MAX(0, model.mainCenterPoint.x);
    originX = MIN(originX, layer.bounds.size.width-textBounds.size.width);
    textLayer.frame = CGRectMake(originX, y, textBounds.size.width, textBounds.size.height);
    textLayer.contentsScale = UIScreen.mainScreen.scale;
    [layer addSublayer:textLayer];
}

@end
