 

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

typedef enum {
    NETWORK_TYPE_NONE= 0,
    NETWORK_TYPE_2G= 1,
    NETWORK_TYPE_3G= 2,
    NETWORK_TYPE_4G= 3,
    NETWORK_TYPE_5G= 4,//  5G目前为猜测结果
    NETWORK_TYPE_WIFI= 5,
}NETWORK_TYPE;

@interface ToolUtil : NSObject

//md5
+ (NSString *)MD5Code:(NSString *)value;

//date
+ (NSString *)FormatTime:(NSString *)format timeInterval:(double)value;
+ (double)TimeStrToTimeInterval:(NSString *)format timeStr:(NSString *)time;

//lbs distance
+ (NSString *)calculateDistance:(long long)lat1 lng1:(long long)lng1 lat2:(long long)lat2 lng2:(long long)lng2;
+ (long long)calculateDistanceRaw:(long long)lat1 lng1:(long long)lng1 lat2:(long long)lat2 lng2:(long long)lng2;

//dateFormate
+ (NSString *)prettyTime2:(long long)timeInSeconds;
+ (NSString *)prettyTime3:(long long)timeInSeconds;

//正则判断手机号码地址格式
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

//检查上一次缓存是否过期
+(BOOL)checkMoreThanOneDayNeedRequest:(NSString *)lastAskTimeKey;

//attribute text height
+ (CGFloat)calculating_Text_Height_IOS7_Width:(CGFloat)width WithString:(NSAttributedString *)string ;

//netStatu
+(NETWORK_TYPE)getNetworkTypeFromStatusBar ;

@end
