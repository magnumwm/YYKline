//
//  YYKlineStyleConfig.m
//  YYKline
//
//  Created by aqumon on 2021/2/20.
//  Copyright © 2021 WillkYang. All rights reserved.
//

#import "YYKlineStyleConfig.h"
#import "UIColor+YYKline.h"
#import "YYKlineGlobalVariable.h"

@implementation YYKlineStyleConfig
@synthesize kLineWidth = _kLineWidth;
@synthesize kLineGap = _kLineGap;

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    static YYKlineStyleConfig *config;
    dispatch_once(&onceToken, ^{
        config = [YYKlineStyleConfig new];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadDefault];
    }
    return self;
}

- (void)loadDefault {
    // 颜色
    self.backgroundColor = [UIColor whiteColor];
    self.assistBackgroundColor = [UIColor whiteColor];
    self.upColor = [UIColor upColor];
    self.downColor = [UIColor downColor];
    self.volumeUpColor = [UIColor upColor];
    self.volumeDownColor = [UIColor downColor];
    self.mainTextColor = [UIColor mainTextColor];
    self.timeLineColor = [UIColor grayColor];
    self.timeLineLineColor = [UIColor colorWithRed:238/255.0 green:47/255.0 blue:121/255.0 alpha:1.0];
    self.timelineGradientStartColor = [UIColor colorWithRed:238/255.0 green:47/255.0 blue:121/255.0 alpha:0.2];
    self.timelineGradientEndColor = [UIColor colorWithRed:238/255.0 green:47/255.0 blue:121/255.0 alpha:0];
    self.crossLineColor = [UIColor longPressLineColor];
    self.crossLineTextColor = [UIColor whiteColor];
    self.crossLineTextBackgroundColor = [UIColor grayColor];
    self.crossLineCenterColor = [UIColor redColor];
    self.crossLineCenterShadowColor = [UIColor redColor];
    self.line1Color = [UIColor line1Color];
    self.line2Color = [UIColor line2Color];
    self.line3Color = [UIColor line3Color];

    // 字体
    self.timelineFontName = @"Helvetica";
    self.timelineFont = [UIFont systemFontOfSize:12];
    self.klineCategoryFont = [UIFont systemFontOfSize:14];
    self.crosslineTextFont = [UIFont systemFontOfSize:12];
    self.klinePropertyTextFont = [UIFont systemFontOfSize:12];
    self.klinePropertyValueFont = [UIFont systemFontOfSize:13];

    // 布局
    self.zoomLevel = 1.f;
//    self.klineLineMinWidth = YYKlineLineMinWidth;
//    self.klineLineMaxWidth = YYKlineLineMaxWidth;
    self.kLineLineWidth = YYKlineLineWidth;
    self.kTimelineLineWidth = 2.4;
    self.kLineWidth = [YYKlineGlobalVariable kLineWidth];
    self.kLineGap = [YYKlineGlobalVariable kLineGap];
    self.kCandleRadius = 4.5;
    self.kVolumeBarRadius = 1.0;
    self.kLineMainViewRadio = [YYKlineGlobalVariable kLineMainViewRadio];
    self.kLineVolumeViewRadio = [YYKlineGlobalVariable kLineVolumeViewRadio];
    self.kLineCrosslineWidth = YYKlineLineWidth;
    self.kLineCrossCenterRadius = 4;
    self.kLineCrossTextHeight = 15;
    self.kLineCrossTextInset = UIEdgeInsetsMake(4, 4, 4, 4);
    self.mainToTimelineGap = 12;
    self.mainAreaHeight = 187;
    self.timelineAreaHeight = 12;
    self.timelineToVolumeGap = 16;
    self.volumeAreaHeight = 32;

    // 股票市场绘制参数
    self.drawVolChart = YES;
    self.drawXAxisTimeline = YES;
    self.drawYAxisPrice = YES;
}

//- (CGFloat)kLineWidth {
//    CGFloat width = _kLineWidth * self.zoomLevel;
//    width = MAX(self.klineLineMinWidth, width);
//    width = MIN(width, self.klineLineMaxWidth);
//    return width;
//}
- (void)setZoomLevel:(CGFloat)zoomLevel {
    _zoomLevel = zoomLevel;
    self.kLineWidth = _kLineWidth * self.zoomLevel;
    self.kLineGap = _kLineGap * self.zoomLevel;
}

- (void)setKLineWidth:(CGFloat)kLineWidth {
    if (kLineWidth > YYKlineLineMaxWidth) {
        kLineWidth = YYKlineLineMaxWidth;
    }else if (kLineWidth < YYKlineLineMinWidth){
        kLineWidth = YYKlineLineMinWidth;
    }
    _kLineWidth = kLineWidth;
}

//- (CGFloat)kLineGap {
//    CGFloat width = _kLineGap * self.zoomLevel;
//    width = MAX(0, width);
//    width = MIN(width, 5);
//    return width;
//}

- (void)setKLineGap:(CGFloat)kLineGap {
    if (kLineGap > YYKlineLineMaxGap) {
        kLineGap = YYKlineLineMaxGap;
    }else if (kLineGap < YYKlineLineMinGap){
        kLineGap = YYKlineLineMinGap;
    }
    _kLineGap = kLineGap;
}

- (CGFloat)mainToTimelineGap {
    if (self.drawXAxisTimeline) {
        return _mainToTimelineGap;
    }
    return 0;
}

- (CGFloat)timelineAreaHeight {
    if (self.drawXAxisTimeline) {
        return _timelineAreaHeight;
    }
    return 0;
}

- (CGFloat)timelineToVolumeGap {
    if (self.drawVolChart) {
        return _timelineToVolumeGap;
    }
    return 0;
}

- (CGFloat)volumeAreaHeight {
    if (self.drawVolChart) {
        return _volumeAreaHeight;
    }
    return 0;
}

@end
