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

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    static YYKlineStyleConfig *config;
    dispatch_once(&onceToken, ^{
        config = [YYKlineStyleConfig new];
        [config loadDefault];
    });
    return config;
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
    self.kLineLineWidth = YYKlineLineWidth;
    self.kTimelineLineWidth = 2.4;
    self.kLineWidth = [YYKlineGlobalVariable kLineWidth];
    self.kLineGap = [YYKlineGlobalVariable kLineGap];
    self.kLineMainViewRadio = [YYKlineGlobalVariable kLineMainViewRadio];
    self.kLineVolumeViewRadio = [YYKlineGlobalVariable kLineVolumeViewRadio];
    self.kLineCrosslineWidth = YYKlineLineWidth;
    self.kLineCrossCenterRadius = 4;
    self.kLineCrossTextHeight = 15;
    self.kLineCrossTextInset = UIEdgeInsetsMake(4, 4, 4, 4);
}

- (void)setKLineWidth:(CGFloat)kLineWidth {
    if (kLineWidth > YYKlineLineMaxWidth) {
        kLineWidth = YYKlineLineMaxWidth;
    }else if (kLineWidth < YYKlineLineMinWidth){
        kLineWidth = YYKlineLineMinWidth;
    }
    _kLineWidth = kLineWidth;
}

@end
