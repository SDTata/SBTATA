//
//  DeviceUUID.m
//  phonelive2
//
//  Created by 400 on 2021/6/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import "DeviceUUID.h"
#import "XYUUID.h"
#import "XYKeyChain.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


static NSString *STR_XYUUIDForInstall = @"XYUUID-Install";
static NSString *STR_XYUUIDForKeyChain = @"XYUUID-KeyChain-ServiceDomain";
static NSString *STR_XYUUIDForKeyChainAndDeviceOrIdfa = @"XYUUID-KeyChain-Device-Idfa";
static NSString *STR_XYUUIDForKeyChainAndDeviceFromServer = @"XYUUID-KeyChain-Device-uuidServer";

static NSString *STR_XYUUIDForKeyChainAndDeviceFromAli = @"XYUUID-KeyChain-Device-uuidAliDevice";

static NSString *STR_XYUUIDForKeyChainAndDeviceFromWangyi = @"XYUUID-KeyChain-Device-uuidWangyiDeviceNew1";


static NSString *XY_ZeroIdfa = @"00000000-0000-0000-0000-000000000000";

@implementation DeviceUUID

+ (NSString *)uuidForPhoneDevice {
 
    NSString *deviceUUID = [XYKeyChain getDataWithServiceDomain:STR_XYUUIDForKeyChainAndDeviceOrIdfa];
    if (deviceUUID && ![deviceUUID isEqualToString:@""] && ![deviceUUID isEqualToString:XY_ZeroIdfa]) {
        return [NSString stringWithFormat:@"%@",deviceUUID];
    }
    
    NSString *idfa = [XYUUID uuidForIDFA];
    if (idfa && ![idfa isEqualToString:@""] && ![idfa isEqualToString:XY_ZeroIdfa]) {
        [XYKeyChain setData:idfa serviceDomain:STR_XYUUIDForKeyChainAndDeviceOrIdfa];
        return idfa;
    }
    
    NSString *deviceInfoUUID = [XYUUID uuidForDeviceInfo];
    if (deviceInfoUUID && ![deviceInfoUUID isEqualToString:@""]) {
        [XYKeyChain setData:deviceInfoUUID serviceDomain:STR_XYUUIDForKeyChainAndDeviceOrIdfa];
        return deviceInfoUUID;
    }
    
    NSString *uuid = [XYUUID uuid];
    if (uuid && ![uuid isEqualToString:@""]) {
        [XYKeyChain setData:uuid serviceDomain:STR_XYUUIDForKeyChainAndDeviceOrIdfa];
        return uuid;
    }
    
    return @"";
}

/////


///wangyidevice
+ (NSString*)uuidFromWangyiDevice{
    NSString *deviceUUID = [XYKeyChain getDataWithServiceDomain:STR_XYUUIDForKeyChainAndDeviceFromWangyi];
    if (deviceUUID && ![deviceUUID isEqualToString:@""] && ![deviceUUID isEqualToString:XY_ZeroIdfa]) {
        return deviceUUID;
    }
    return @"";
}


+ (void)setWangyiDevice:(NSString*)uuidStr{
    if (uuidStr && ![uuidStr isEqualToString:@""] && ![uuidStr isEqualToString:XY_ZeroIdfa]) {
        [XYKeyChain setData:uuidStr serviceDomain:STR_XYUUIDForKeyChainAndDeviceFromWangyi];
    }
}


@end
