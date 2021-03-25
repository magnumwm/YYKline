//
//  Y-KlineGroupModel.m
//  YYKline
//
//  Copyright © 2016年 WillkYang. All rights reserved.
//

#import "YYKlineRootModel.h"
#import "YYKlineStyleConfig.h"

@implementation YYKlineRootModel
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
        model.Timestamp = item[5];
        model.drawTime = model.V_Date;
        // value为NSNull时设置成上一个model的值
        model.Open = [item[0] isKindOfClass:NSNull.class] ? model.PrevModel.Close : item[0];
        model.High = [item[1] isKindOfClass:NSNull.class] ? model.PrevModel.High : item[1];
        model.Low = [item[2] isKindOfClass:NSNull.class] ? model.PrevModel.Low : item[2];
        model.Close = [item[3] isKindOfClass:NSNull.class] ? model.PrevModel.Close : item[3];
        model.Volume = [item[4] isKindOfClass:NSNull.class] ? model.PrevModel.Volume : item[4];

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

@end
