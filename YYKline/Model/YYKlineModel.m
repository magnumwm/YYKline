//
//  YYKlineModel.m
//  YYKline
//
//  Copyright © 2019 WillkYang. All rights reserved.
//

#import "YYKlineModel.h"
#import "YYKlineStyleConfig.h"

@implementation YYKlineModel

- (NSString *)V_Date {
    if (!_V_Date) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_Timestamp];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"MM-dd";
        NSString *dateStr = [formatter stringFromDate:date];
        _V_Date = dateStr;
    }
    return _V_Date;
}

- (NSString *)V_HHMM {
    if (!_V_HHMM) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_Timestamp];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"HH:mm";
        NSString *dateStr = [formatter stringFromDate:date];
        _V_HHMM = dateStr;
    }
    return _V_HHMM;
}

- (NSAttributedString *)V_Price {
    if (!_V_Price) {
        _V_Price = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %f  开：%.3f  高：%.3f 低：%.3f  收：%.3f ", _Timestamp, self.Open, self.High, self.Low, self.Close] attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
    }
    return _V_Price;
}

- (NSAttributedString *)V_MA {
    if (!_V_MA) {
        YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@  开：%.3f  高：%.3f 低：%.3f  收：%.3f ", self.V_Date, self.Open, self.High, self.Low, self.Close] attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" MA10：%.3f ",self.MA.MA1.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line1Color,
        }];
        NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" MA30：%.3f ",self.MA.MA2.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line2Color,
        }];
        NSAttributedString *str4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" MA60：%.3f ",self.MA.MA3.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line3Color,
        }];
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:str1];
        [mStr appendAttributedString:str2];
        [mStr appendAttributedString:str3];
        [mStr appendAttributedString:str4];
        _V_MA = [mStr copy];
    }
    return _V_MA;
}

- (NSAttributedString *)V_EMA {
    if (!_V_EMA) {
        YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@  开：%.3f  高：%.3f 低：%.3f  收：%.3f ", self.V_Date, self.Open, self.High, self.Low, self.Close] attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" EMA7：%.3f ",self.EMA.EMA1.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line1Color,
        }];
        NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" EMA30：%.3f ",self.EMA.EMA2.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line2Color,
        }];
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:str1];
        [mStr appendAttributedString:str2];
        [mStr appendAttributedString:str3];
        _V_EMA = [mStr copy];
    }
    return _V_EMA;
}

- (NSAttributedString *)V_BOLL {
    if (!_V_BOLL) {
        YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@  开：%.3f  高：%.3f 低：%.3f  收：%.3f ", self.V_Date, self.Open, self.High, self.Low, self.Close] attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" UP：%.3f ",self.BOLL.UP.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line1Color,
        }];
        NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" MID：%.3f ",self.BOLL.MID.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line2Color,
        }];
        NSAttributedString *str4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" LOW：%.3f ",self.BOLL.LOW.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line3Color,
        }];
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:str1];
        [mStr appendAttributedString:str2];
        [mStr appendAttributedString:str3];
        [mStr appendAttributedString:str4];
        _V_BOLL = [mStr copy];
    }
    return _V_BOLL;
}

- (NSAttributedString *)V_Volume {
    if (!_V_Volume) {
        _V_Volume = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" 成交量：%.0f", self.Volume] attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
    }
    return _V_Volume;
}

- (NSAttributedString *)V_MACD {
    if (!_V_MACD) {
        YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@" MACD(12,26,9)：" attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" DIFF：%.4f ",self.MACD.DIFF.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line1Color,
        }];
        NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" DEA：%.4f ",self.MACD.DEA.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line2Color,
        }];
        NSAttributedString *str4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" MACD：%.4f ",self.MACD.MACD.floatValue] attributes:@{
            NSForegroundColorAttributeName: self.MACD.MACD.floatValue < 0 ? config.upColor : config.downColor,
        }];
        
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:str1];
        [mStr appendAttributedString:str2];
        [mStr appendAttributedString:str3];
        [mStr appendAttributedString:str4];
        _V_MACD = [mStr copy];
    }
    return _V_MACD;
}

- (NSAttributedString *)V_KDJ {
    if (!_V_KDJ) {
        YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@" KDJ(9,3,3)：" attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" K：%.3f ",self.KDJ.K.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line1Color,
        }];
        NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" D：%.3f ",self.KDJ.D.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line2Color,
        }];
        NSAttributedString *str4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" J：%.3f ",self.KDJ.J.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line3Color,
        }];
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:str1];
        [mStr appendAttributedString:str2];
        [mStr appendAttributedString:str3];
        [mStr appendAttributedString:str4];
        _V_KDJ = [mStr copy];
    }
    return _V_KDJ;
}

- (NSAttributedString *)V_RSI {
    if (!_V_RSI) {
        YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@" RSI(6,12,24)：" attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" RSI6：%.3f ",self.RSI.RSI1.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line1Color,
        }];
        NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" RSI12：%.3f ",self.RSI.RSI2.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line2Color,
        }];
        NSAttributedString *str4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" RSI24：%.3f ",self.RSI.RSI3.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line3Color,
        }];
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:str1];
        [mStr appendAttributedString:str2];
        [mStr appendAttributedString:str3];
        [mStr appendAttributedString:str4];
        _V_RSI = [mStr copy];
    }
    return _V_RSI;
}

- (NSAttributedString *)V_WR {
    if (!_V_WR) {
        YYKlineStyleConfig *config = YYKlineStyleConfig.sharedConfig;
        NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@" WR(6,10)：" attributes:@{
            NSForegroundColorAttributeName: [UIColor grayColor],
        }];
        NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" WR6：%.3f ",self.WR.WR1.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line1Color,
        }];
        NSAttributedString *str3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" WR10：%.3f ",self.WR.WR2.floatValue] attributes:@{
            NSForegroundColorAttributeName: config.line2Color,
        }];
        NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:str1];
        [mStr appendAttributedString:str2];
        [mStr appendAttributedString:str3];
        _V_WR = [mStr copy];
    }
    return _V_WR;
}

- (BOOL)isUp {
    return self.Close >= self.Open;
}

- (NSString *)changePercent {
    if (self.PrevModel.Close <= 0) return @"--";
    CGFloat change = (self.Close - self.PrevModel.Close)/self.PrevModel.Close*100;
    return [NSString stringWithFormat:@"%.2f%%", change];
}

- (NSString *)changeAmount {
    if (self.PrevModel.Close <= 0) return @"--";
    CGFloat change = (self.Close - self.PrevModel.Close);
    return [NSString stringWithFormat:@"%.2f", change];
}

@end

