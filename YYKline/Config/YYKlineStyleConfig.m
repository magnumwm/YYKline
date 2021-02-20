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

+ (instancetype)config {
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
    self.backgroundColor = [UIColor backgroundColor];
    self.assistBackgroundColor = [UIColor assistBackgroundColor];
    self.upColor = [UIColor upColor];
    self.downColor = [UIColor downColor];
    self.mainTextColor = [UIColor mainTextColor];
    self.timeLineLineColor = [UIColor timeLineLineColor];
    self.crossLineColor = [UIColor longPressLineColor];
    self.crossLineLabelColor = [UIColor whiteColor];
    self.crossLineLabelBackgroundColor = [UIColor grayColor];
    self.crossLineCenterColor = [UIColor redColor];
    self.line1Color = [UIColor line1Color];
    self.line2Color = [UIColor line2Color];
    self.line3Color = [UIColor line3Color];

    // 字体
    self.timelineFont = [UIFont systemFontOfSize:12];
    self.klineCategoryFont = [UIFont systemFontOfSize:14];
    self.crosslineLabelFont = [UIFont systemFontOfSize:12];
    self.klinePropertyTextFont = [UIFont systemFontOfSize:12];
    self.klinePropertyValueFont = [UIFont systemFontOfSize:13];

    // 布局
    self.kLineLineWidth = YYKlineLineWidth;
    self.kLineWidth = [YYKlineGlobalVariable kLineWidth];
    self.kLineGap = [YYKlineGlobalVariable kLineGap];
    self.kLineMainViewRadio = [YYKlineGlobalVariable kLineMainViewRadio];
    self.kLineVolumeViewRadio = [YYKlineGlobalVariable kLineVolumeViewRadio];
    self.kLineCrosslineWidth = YYKlineLineWidth;
    self.kLineCrossCenterRadius = 4;
}

@end
