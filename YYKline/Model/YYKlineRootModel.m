//
//  Y-KlineGroupModel.m
//  YYKline
//
//  Copyright © 2016年 WillkYang. All rights reserved.
//

#import "YYKlineRootModel.h"
#import "YYKlineStyleConfig.h"

const NSInteger kChinaStockTimeFramesMaxCount = 241;
const NSInteger kHKStockTimeFramesMaxCount = 331;
const NSInteger kUSStockTimeFramesMaxCount = 391;
const NSInteger kStockPriceNullValue = -1;

@implementation YYKlineRootModel

#pragma mark -
#pragma mark 解析CGFloat
+ (CGFloat)parseFloat:(id)object
{
    if ([object isKindOfClass:[NSNumber class]] == NO &&
        [object isKindOfClass:[NSString class]] == NO) {
        return 0.0;
    }

    return [object doubleValue];
}

- (id)copyWithZone:(NSZone *)zone {
    YYKlineRootModel *copy = [[[self class] allocWithZone:zone] init];
    copy.models = _models;
    return copy;
}

//! @brief 将服务器返回的数据填充到预先生成的stockTimeFrames中
- (void)populateResponseArray:(NSArray *)arr{
    for (NSInteger i = [arr count]-1; i>=0; i--) {
        NSArray *item = arr[i];
        NSNumber *timeStamp = item[5];
        if ([timeStamp isKindOfClass:NSNumber.class]) {
            NSNumber *indexObj = [self.stockTimeFramesIndexDict objectForKey:timeStamp];
            if ([indexObj isKindOfClass:NSNumber.class]) {
                YYKlineModel *model = [self.models objectAtIndex:[indexObj integerValue]];
                model.Open = [YYKlineRootModel parseFloat:item[0]];
                model.High = [YYKlineRootModel parseFloat:item[1]];
                model.Low = [YYKlineRootModel parseFloat:item[2]];
                model.Close = [YYKlineRootModel parseFloat:item[3]];
                model.Volume = [YYKlineRootModel parseFloat:item[4]];
//                NSLog(@"indexObj:%@, timeStamp:%@", indexObj, timeStamp);
            }
            else {
                // 如果timeStamp > self.models.lastObjc.timestamp 填充到最后一个时间点
                if (self.models.lastObject.Timestamp < timeStamp.doubleValue) {
                    YYKlineModel *model = self.models.lastObject;
                    model.Open = [YYKlineRootModel parseFloat:item[0]];
                    model.High = [YYKlineRootModel parseFloat:item[1]];
                    model.Low = [YYKlineRootModel parseFloat:item[2]];
                    model.Close = [YYKlineRootModel parseFloat:item[3]];
                    model.Volume = [YYKlineRootModel parseFloat:item[4]];
                }
            }
        }
    }
    NSLog(@"%ld", self.models.count);
}

+ (instancetype)objectWithArray:(NSArray *)arr{
    NSAssert([arr isKindOfClass:[NSArray class]], @"arr不是一个数组，请检查返回数据类型并手动适配");
    YYKlineRootModel *groupModel = [YYKlineRootModel new];
    NSMutableArray *mArr = @[].mutableCopy;
    NSInteger index = 0;
    for (NSInteger i = [arr count]-1; i>=0; i--) {
        NSArray *item = arr[i];
        YYKlineModel *model = [YYKlineModel new];
        model.index = index;
        model.PrevModel = mArr.lastObject;
        model.Timestamp = [self parseFloat:item[5]];

        model.Open = [item[0] isKindOfClass:NSNull.class] ? kStockPriceNullValue : [self parseFloat:item[0]];
        model.High = [item[1] isKindOfClass:NSNull.class] ? kStockPriceNullValue : [self parseFloat:item[1]];
        model.Close = [item[3] isKindOfClass:NSNull.class] ? kStockPriceNullValue : [self parseFloat:item[3]];
        model.Low = [item[2] isKindOfClass:NSNull.class] ? kStockPriceNullValue : [self parseFloat:item[2]];
        model.Volume = [self parseFloat:item[4]];

        [mArr addObject:model];
        index++;
    }
    groupModel.models = mArr;
//    [groupModel calculateIndicators:YYKlineIncicatorMACD];
//    [groupModel calculateIndicators:YYKlineIncicatorMA];
//    [groupModel calculateIndicators:YYKlineIncicatorKDJ];
//    [groupModel calculateIndicators:YYKlineIncicatorRSI];
//    [groupModel calculateIndicators:YYKlineIncicatorBOLL];
//    [groupModel calculateIndicators:YYKlineIncicatorWR];
//    [groupModel calculateIndicators:YYKlineIncicatorEMA];
    return groupModel;
}

- (void)calculateIndicators:(YYKlineIncicator)key {
    switch (key) {
        case YYKlineIncicatorMA:
            [YYMAModel calMAWithData:self.models params:@[@"10",@"30",@"60"]];
            break;
        case YYKlineIncicatorMACD:
            [YYMACDModel calMACDWithData:self.models params:@[@"12",@"26",@"9"]];
            break;
        case YYKlineIncicatorKDJ:
            [YYKDJModel calKDJWithData:self.models params:@[@"9",@"3",@"3"]];
            break;
        case YYKlineIncicatorRSI:
            [YYRSIModel calRSIWithData:self.models params:@[@"6",@"12",@"24"]];
            break;
        case YYKlineIncicatorWR:
            [YYWRModel calWRWithData:self.models params:@[@"6",@"10"]];
            break;
        case YYKlineIncicatorEMA:
            [YYEMAModel calEmaWithData:self.models params:@[@"7",@"30"]];
            break;
        case YYKlineIncicatorBOLL:
            [YYBOLLModel calBOLLWithData:self.models params:@[@"20",@"2"]];
            break;
    }
}


/**
 * 根据交易日数组，预生成对应交易日的YYKlineRootModel
 */
+ (instancetype)stockTimeFrames:(NSArray<NSNumber *> *)tradeDates marketType:(NSInteger)marketType{
    // marketType: 0:HK, 1:US, 2:CN
    NSMutableArray *allModels = @[].mutableCopy;
    NSMutableDictionary *allMaps = @{}.mutableCopy;
    if (marketType == 1) {
        for (NSInteger index = 0; index < tradeDates.count; index++) {
            NSNumber *date = tradeDates[index];
            NSTimeInterval timeInterval = [date doubleValue];
            YYKlineRootModel *rootModel = [self usStockTimeFrames:timeInterval fromIndex:index*kUSStockTimeFramesMaxCount];
            [allModels addObjectsFromArray:rootModel.models];
            [allMaps addEntriesFromDictionary:rootModel.stockTimeFramesIndexDict];
        }
    } else if (marketType == 2) {
        for (NSInteger index = 0; index < tradeDates.count; index++) {
            NSNumber *date = tradeDates[index];
            NSTimeInterval timeInterval = [date doubleValue];
            YYKlineRootModel *rootModel = [self chinaStockTimeFrames:timeInterval fromIndex:index*kChinaStockTimeFramesMaxCount];
            [allModels addObjectsFromArray:rootModel.models];
            [allMaps addEntriesFromDictionary:rootModel.stockTimeFramesIndexDict];
        }
    } else {
        for (NSInteger index = 0; index < tradeDates.count; index++) {
            NSNumber *date = tradeDates[index];
            NSTimeInterval timeInterval = [date doubleValue];
            YYKlineRootModel *rootModel = [self hkStockTimeFrames:timeInterval fromIndex:index*kHKStockTimeFramesMaxCount];
            [allModels addObjectsFromArray:rootModel.models];
            [allMaps addEntriesFromDictionary:rootModel.stockTimeFramesIndexDict];
        }
    }
    YYKlineRootModel *model = [YYKlineRootModel new];
    model.models = allModels;
    model.stockTimeFramesIndexDict = allMaps;
    return model;
}

/**
 * A股分时数据 241个点
 * A股市场的交易时间为每周一到周五上午时段9:30-11:30，下午时段13:00-15:00，
 * 其中上午9:15-9:25为早盘集合竞价时间，14:57-15:00为收盘集合竞价时间。
 */
+ (instancetype)chinaStockTimeFrames:(NSTimeInterval)latestTime fromIndex:(NSInteger)startIndex{
    NSInteger openInterval = [self getTimeStampOfTheDay:latestTime zone:[NSTimeZone timeZoneWithName:@"Asia/Hong_Kong"]];
    return [self generateStockTimeFrames:kChinaStockTimeFramesMaxCount openTime:openInterval compension:90 fromIndex:startIndex];
}
/**
 * 港股股分时数据 331个点
 * 港股交易时间：分为开市前时段、早市、午市、收市四个时段，上午9:30至上午10:00开市前竞价时段；
 * 上午9:30至中午12:00早市，下午13:00至下午16:00午市，下午16:00-16:10随机收市竞价。
 */
+ (instancetype)hkStockTimeFrames:(NSTimeInterval)latestTime fromIndex:(NSInteger)startIndex{
    NSInteger openInterval = [self getTimeStampOfTheDay:latestTime zone:[NSTimeZone timeZoneWithName:@"Asia/Hong_Kong"]];
    return [self generateStockTimeFrames:kHKStockTimeFramesMaxCount openTime:openInterval compension:60 fromIndex:startIndex];
}
/**
 * 美股分时数据 391个点
 * 周一到周五，分正常交易和盘前盘后两个交易时段。
 * 美股开盘时间为美东时间：早上9点30分（北京时间22:30 夏令时为：21:30 ）
 * 正常交易时间分为冬令时和夏令时：
 * 夏令时(每年4月初到11月初采用夏令时)：北京时间晚9:30-次日凌晨4:00；
 * 冬令时(每年11月初到4月初采用冬令时)：北京时间晚10:30-次日凌晨5:00。
 * 经过多次修改后，美股的熔断机制分了7%、13%和20%这三档阈值。
 */
+ (instancetype)usStockTimeFrames:(NSTimeInterval)latestTime fromIndex:(NSInteger)startIndex{
    NSInteger openInterval = [self getTimeStampOfTheDay:latestTime zone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];
    return [self generateStockTimeFrames:kUSStockTimeFramesMaxCount openTime:openInterval compension:0 fromIndex:startIndex];
}

//! @brief 预生成A股/港股/美股分时图数据点, 补偿点 A股从11:30往后补偿90个点，港股从12点往后补偿60个点，美股不补偿
+ (instancetype)generateStockTimeFrames:(NSInteger)count
                               openTime:(NSTimeInterval)openTime
                             compension:(NSInteger)compension
                              fromIndex:(NSInteger)startIndex{
    YYKlineRootModel *groupModel = [YYKlineRootModel new];
    NSMutableArray *mArr = @[].mutableCopy;
    NSMutableDictionary *indexDict = [NSMutableDictionary new];
    NSInteger index = startIndex;
    for (NSInteger i = 0; i < count ; i++) {
        YYKlineModel *model = [YYKlineModel new];
        model.index = index;
        model.PrevModel = mArr.lastObject;
        model.Timestamp = (openTime+60*i);
        if (compension == 90 && i >= 121) {
            // A股从第121个点开始补偿
            model.Timestamp = (openTime+60*(i+compension));
        } else if (compension == 60 && i >= 151) {
            // 港股从第151个点开始补偿
            model.Timestamp = (openTime+60*(i+compension));
        } else {
            model.Timestamp = (openTime+60*i);
        }
        [indexDict setObject:@(index) forKey:@(model.Timestamp)];

        model.Open = kStockPriceNullValue;
        model.High = kStockPriceNullValue;
        model.Low = kStockPriceNullValue;
        model.Close = kStockPriceNullValue;
        model.Volume = kStockPriceNullValue;

        [mArr addObject:model];
        index++;
    }
    groupModel.models = mArr;
    groupModel.stockTimeFramesIndexDict = indexDict;
    return groupModel;
}

// 获取指定时区9点半开盘时间
+ (NSInteger)getTimeStampOfTheDay:(NSTimeInterval)time zone:(NSTimeZone *)zone {
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = zone;
    }
    NSDate *zeroDate = [self getZeroOfTheDay:time zone:zone];
    NSDate *nine30 = [zeroDate dateByAddingTimeInterval:(9*60*60+30*60)];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSInteger interval = [nine30 timeIntervalSince1970];
//    NSLog(@"%@, interval: %ld, zone:%@", [dateFormatter stringFromDate:nine30], interval, zone.name);
    return interval;
}

#warning 需要从服务器获取最近一个交易日零点时间
// 获取指定时区的零点时间
+ (NSDate*)getZeroOfTheDay:(NSTimeInterval)time zone:(NSTimeZone *)zone{

    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = zone;

    // 当前时间
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:time];

    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];

    NSDate *startDate = [calendar dateFromComponents:components];

    return startDate;
}
@end
