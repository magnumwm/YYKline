//
//  YYKlineView.h
//  YYKline
//
//  Copyright © 2016年 WillkYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYKlineConstant.h"
#import "YYKlineModel.h"
#import "YYKlineRootModel.h"
#import "YYPainterProtocol.h"

@protocol YYKlineViewDelegate <NSObject>

- (void)yyklineviewUpdateText:(YYKlineModel *)model;
- (void)yyklineviewEndLongPressChart:(YYKlineModel *)model;

@end

@interface YYKlineView : UIView

@property(nonatomic, weak) id<YYKlineViewDelegate> delegate;

/// 绘制源数据
@property(nonatomic, strong) YYKlineRootModel *rootModel;

/// 绘制参数
@property (nonatomic, strong) YYKlineStyleConfig *styleConfig;

- (instancetype)initWithStyleConfig:(YYKlineStyleConfig *)config;
/// 重置scrollView偏移量，切换日K/周K/年K时需要重置
- (void)resetContentOffset;
/// 重绘K线蜡烛图
- (void)reDrawCandle:(CGFloat)currentPrice;
/// 重绘分时图
- (void)reDrawTimeline:(CGFloat)currentPrice;
/// 分时/五日不能滚动，日K/周K等可以滚动和缩放
- (void)enableScrollAndZoom:(BOOL)enable;
@end
