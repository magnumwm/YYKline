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

@property(nonatomic, strong) YYKlineRootModel *rootModel; // 数据

@property (nonatomic) Class<YYPainterProtocol> linePainter;
//@property (nonatomic) Class <YYPainterProtocol> indicator1Painter;
//@property (nonatomic) Class <YYPainterProtocol> indicator2Painter;
@property (nonatomic) Class<YYCrossLinePainterProtocol> crossPainter;
@property (nonatomic) Class<YYCurrentPricePainterProtocol> currentPricePainter;

- (instancetype)initWithStyleConfig:(YYKlineStyleConfig *)config;
/// 重绘
- (void)reDraw:(CGFloat)currentPrice;
/// 分时/五日不能滚动，日K/周K等可以滚动和缩放
- (void)enableScrollAndZoom:(BOOL)enable;
@end
