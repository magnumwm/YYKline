//
//  Y-KlineGroupModel.h
//  YYKline
//
//  Copyright © 2016年 WillkYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "YYKlineModel.h"

/**
 * A股分时图数据点数量
 */
extern const NSInteger kChinaStockTimeFramesMaxCount;

/**
 * 港股分时图数据点数量
 */
extern const NSInteger kHKStockTimeFramesMaxCount;

/**
 * US股分时图数据点数量
 */
extern const NSInteger kUSStockTimeFramesMaxCount;

typedef NS_ENUM(NSInteger, YYKlineIncicator) {
    YYKlineIncicatorMA = 100,        // MA线
    YYKlineIncicatorEMA,        // EMA线
    YYKlineIncicatorBOLL,       // BOLL线
    YYKlineIncicatorMACD = 104,   //MACD线
    YYKlineIncicatorKDJ,        // KDJ线
    YYKlineIncicatorRSI,         // RSI
    YYKlineIncicatorWR,         // WR
    
};

@interface YYKlineRootModel : NSObject<NSCopying>

+ (instancetype)objectWithArray:(NSArray *)arr;

//! @brief 包含分时数据或者K线数据
@property (nonatomic, copy) NSArray<YYKlineModel *> *models;

//! @brief 时间戳-index
@property (nonatomic, strong) NSDictionary *stockTimeFramesIndexDict;

/**
 * 根据交易日数组(TimeInterval)，预生成对应交易日的YYKlineRootModel
 */
+ (instancetype)stockTimeFrames:(NSArray<NSNumber *> *)tradeDates marketType:(NSInteger)marketType;

/**
 * A股分时数据 241个点
 * A股市场的交易时间为每周一到周五上午时段9:30-11:30，下午时段13:00-15:00，
 * 其中上午9:15-9:25为早盘集合竞价时间，14:57-15:00为收盘集合竞价时间。
 */
+ (instancetype)chinaStockTimeFrames:(NSTimeInterval)latestTime fromIndex:(NSInteger)startIndex;

/**
 * 港股股分时数据 331个点
 * 港股交易时间：分为开市前时段、早市、午市、收市四个时段，上午9:30至上午10:00开市前竞价时段；
 * 上午9:30至中午12:00早市，下午13:00至下午16:00午市，下午16:00-16:10随机收市竞价。
 */
+ (instancetype)hkStockTimeFrames:(NSTimeInterval)latestTime fromIndex:(NSInteger)startIndex;

/**
 * 美股分时数据 391个点
 * 周一到周五，分正常交易和盘前盘后两个交易时段。
 * 美股开盘时间为美东时间：早上9点30分（北京时间22:30 夏令时为：21:30 ）
 * 正常交易时间分为冬令时和夏令时：
 * 夏令时(每年4月初到11月初采用夏令时)：北京时间晚9:30-次日凌晨4:00；
 * 冬令时(每年11月初到4月初采用冬令时)：北京时间晚10:30-次日凌晨5:00。
 * 经过多次修改后，美股的熔断机制分了7%、13%和20%这三档阈值。
 */
+ (instancetype)usStockTimeFrames:(NSTimeInterval)latestTime fromIndex:(NSInteger)startIndex;

//! @brief 将服务器返回的数据填充到预先生成的stockTimeFrames中
- (void)populateResponseArray:(NSArray *)arr;

@end
