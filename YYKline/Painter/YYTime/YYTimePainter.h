//
//  YYTimePainter.h
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "YYPainterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYTimePainter : CALayer <YYXAxisTimeTextPainterProtocol>

/// 绘制单个时间点
/// @param layer 时间轴layer
/// @param config YYKlineStyleConfig
/// @param model 对应的YYKlineModel
+ (void)drawToLayer:(CALayer *)layer
        styleConfig:(YYKlineStyleConfig *)config
              model:(YYKlineModel *)model;


@end

NS_ASSUME_NONNULL_END
