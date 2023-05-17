//
//  KSDeviceTools.m
//  KSFoundation
//
//  Created by Kinsun on 2020/12/7.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSDeviceTools.h"
#import <mach/mach.h>
#import <sys/socket.h> // Per msqr
#import <sys/sysctl.h>
#include <sys/mount.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <sys/ioctl.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/AdSupport.h>
#import "_KSReachability.h"
#import "KSKeyChainTool.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import <objc/runtime.h>

// {'0A', '1B', '2C', '3D', '4E', '5F', '6G', '7H', '8I', '9J', '10K', '11L', '12M', '13N', '14O', '15P', '16Q', '17R', '18S', '19T', '20U', '21V', '22W', '23X', '24Y', '25Z'};
static const char _ks_i[26] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
CTCarrier * _ks_carrier(void) {
    char c[23];
    sprintf(c, "%c%c%celephony%cetwork%cnfo", _ks_i[2], _ks_i[19], _ks_i[19], _ks_i[13], _ks_i[8]);
    CTTelephonyNetworkInfo *info = [[objc_getClass(c) alloc] init];
    if (@available(iOS 13.0, *)) {
        char k[22];
        sprintf(k, "data%cervice%cdentifier", _ks_i[18], _ks_i[8]);
        char s[35];
        sprintf(s, "service%cubscriber%cellular%croviders", _ks_i[18], _ks_i[2], _ks_i[15]);
        return [[info performSelector:sel_registerName(s)] objectForKey:[info performSelector:sel_registerName(k)]];
    } else {
        char s[27];
        sprintf(s, "subscriber%cellular%crovider", _ks_i[2], _ks_i[15]);
        return [info performSelector:sel_registerName(s)];
    }
}

NSString * _ks_getIMSI(void) {
    NSString *mcc = nil;
    NSString *mnc = nil;
    _ks_getMCC_MNC(&mcc, &mnc);
    return [NSString stringWithFormat:@"%@%@", mcc, mnc];
}

void _ks_getMCC_MNC(NSString ** mcc, NSString ** mnc) {
    CTCarrier *carrier = _ks_carrier();
    char cc[18];
    sprintf(cc, "mobile%country%code", _ks_i[2], _ks_i[2]);
    *mcc = [carrier performSelector:sel_registerName(cc)];
    char nc[18];
    sprintf(nc, "mobile%cetwork%code", _ks_i[13], _ks_i[2]);
    *mnc = [carrier performSelector:sel_registerName(nc)];
}

NSString * __ks_getIDFA__(void) {
    @try {
        return ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
    } @catch (NSException *exception) { }
    return nil;
}

void _ks_getIDFA(void (^callback)(BOOL, NSString*)) {
    if (callback != nil) {
        if (@available(iOS 14, *)) {
            [objc_getClass("ATTrackingManager") requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    callback(YES, __ks_getIDFA__());
                }
            }];
        } else {
            callback(NO, __ks_getIDFA__());
        }
    }
}

static NSString * const _ks_kKeychainUUIDItemIdentifier = @"_ks_UUID";

NSString * _ks_getUUID(void) {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSString *uuid = [KSKeyChainTool valueForKey:_ks_kKeychainUUIDItemIdentifier forAccessGroup:bundleIdentifier];
    if (uuid == nil) {
        char nc[20];
        sprintf(nc, "identifier%cor%cendor", _ks_i[5], _ks_i[21]);
        uuid = [[UIDevice.currentDevice performSelector:sel_registerName(nc)] UUIDString];
        [KSKeyChainTool setValue:uuid forKey:_ks_kKeychainUUIDItemIdentifier forAccessGroup:bundleIdentifier];
    }
    return uuid ?: @"";
}

BOOL _ks_resetUUID(void) {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSString *uuid = [KSKeyChainTool valueForKey:_ks_kKeychainUUIDItemIdentifier forAccessGroup:bundleIdentifier];
    if (uuid != nil) {
        return [KSKeyChainTool deleteValueForKey:_ks_kKeychainUUIDItemIdentifier forAccessGroup:bundleIdentifier];
    }
    return NO;
}

NSString * _ks_getDeviceModel(void) {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

NSString * _ks_getCarrierCode(void) {
    return _ks_carrier().mobileNetworkCode;
}

NSInteger _ks_getCarrier(void) {
    NSInteger carrier_name = 0;
    NSString *codeString = _ks_getCarrierCode();
    if (codeString != nil && codeString.length > 0) {
        int code = codeString.intValue;
        switch (code) {
            case 0:
            case 2:
            case 7:
                carrier_name = 2; //移动
                break;
            case 3:
            case 5:
                carrier_name = 3; //电信
                break;
            case 1:
            case 6:
                carrier_name = 1; //联通
                break;
            default:
                carrier_name = 4;
                break;
        }
    }
    return carrier_name;
}

NSString * _ks_getDeviceIPAddress(void) {
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    NSMutableArray *ips = [NSMutableArray array];
    int BUFFERSIZE = 4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0){
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags & IFF_UP) == 0) continue;
            
            NSString *ip = [NSString  stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    
    close(sockfd);
    NSString *deviceIP = [NSString stringWithFormat:@"%@", ips.lastObject];
    return deviceIP;
}

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

NSDictionary * _ks_getIPAddresses(void) {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

NSString * _ks_getNetworkIPAddress(bool isIPv4) {
    NSArray *searchArray = isIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = _ks_getIPAddresses();
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         if (address != nil) *stop = YES;
    }];
    return address ?: @"0.0.0.0";
}

BOOL _ks_getVPNStatus(void) {
    NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *keys = [dict[@"__SCOPED__"] allKeys];
    for (NSString *key in keys) {
        if ([key rangeOfString:@"tap"].location != NSNotFound ||
            [key rangeOfString:@"tun"].location != NSNotFound ||
            [key rangeOfString:@"ipsec"].location != NSNotFound ||
            [key rangeOfString:@"ppp"].location != NSNotFound){
            return YES;
        }
    }
    return NO;
}

BOOL _ks_getProxyStatus(void) {
    NSDictionary *proxySettings = (__bridge NSDictionary*)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef)([NSURL URLWithString:@"https://www.testnetwork.com"]), (__bridge CFDictionaryRef)(proxySettings)));
    NSDictionary *settings = proxies.firstObject;
    return ![[settings objectForKey:(NSString*)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"];
}

NSInteger _ks_GetNetworkType(void) {
    _KSReachability *reachability = [_KSReachability reachabilityForInternetConnection];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWiFi) {
        return 1;
    }
    if (status == ReachableViaWWAN) {
        CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
        NSString *RAT = nil;
        if (@available(iOS 13.0, *)) {
            RAT = [netinfo.serviceCurrentRadioAccessTechnology objectForKey:netinfo.dataServiceIdentifier];
        } else {
            RAT = netinfo.currentRadioAccessTechnology;
        }
        if ([RAT isEqualToString:CTRadioAccessTechnologyGPRS] || [RAT isEqualToString:CTRadioAccessTechnologyEdge]) {
            return 2;
        }
        if ([RAT isEqualToString:CTRadioAccessTechnologyWCDMA] || [RAT isEqualToString:CTRadioAccessTechnologyHSDPA] || [RAT isEqualToString:CTRadioAccessTechnologyHSUPA] || [RAT isEqualToString:CTRadioAccessTechnologyCDMA1x] || [RAT isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [RAT isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [RAT isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] || [RAT isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return 3;
        }
        if ([RAT isEqualToString:CTRadioAccessTechnologyLTE]) {
            return 4;
        }
        if (@available(iOS 14.1, *)) {
            if ([RAT isEqualToString:CTRadioAccessTechnologyNRNSA] || [RAT isEqualToString:CTRadioAccessTechnologyNR]) {
                return 5;
            }
        }
        return 6;
    }
    return 0;
}

NSString * _ks_getCurrentLanguages(void) {
    return [NSLocale.preferredLanguages componentsJoinedByString:@", "];
}

float _ks_device_battery(void) {
    UIDevice *currentDevice = UIDevice.currentDevice;
    currentDevice.batteryMonitoringEnabled = YES;
    float batterylevel = currentDevice.batteryLevel; //获取剩余电量 范围在0.0至 1.0之间
    return batterylevel * 100;
}

double _ks_availableMemory(void) {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return 0.0;
    }
    return ((vm_page_size * vmStats.free_count)/1024.0)/1024.0;
}

unsigned long long _ks_totalMemory(void) {
    return NSProcessInfo.processInfo.physicalMemory;
}

unsigned long long _ks_totalDiskSize(void) {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace;
}

unsigned long long _ks_availableDiskSize(void) {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}

NSTimeInterval _ks_timeStampForNow(void) {
    return NSDate.date.timeIntervalSince1970 * 1000.0;
}

NSString * _ks_charToString(unsigned char *digest, NSUInteger length) {
    NSMutableString *output = [NSMutableString stringWithCapacity:length*2];
    for (NSInteger i = 0; i < length; i++ ) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

NSString * _ks_md5(NSString *string) {
    const char *cStr = string.UTF8String;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    return _ks_charToString(digest, CC_MD5_DIGEST_LENGTH);
}

NSString * _ks_sha1OfData(NSData *data) {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    return _ks_charToString(digest, CC_SHA1_DIGEST_LENGTH);
}

NSString * _ks_sha1OfPath(NSString *path) {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return _ks_sha1OfData(data);
    }
    return nil;
}

BOOL _ks_versionCompare(NSString *str1, NSString *str2) {
    NSInteger comparingResults = [str1 compare:str2 options:NSNumericSearch];
    return comparingResults == NSOrderedDescending || comparingResults == NSOrderedSame;
}

NSData * _ks_AESWithData(NSData *data, CCOperation mode, NSString *key, NSString *iv) {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(mode, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding ,
                                          keyPtr, kCCBlockSizeAES128,
                                          iv.UTF8String,
                                          data.bytes, dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

NSData * _ks_RSA_stripPublicKeyHeader(NSData *key) {
    // Skip ASN.1 public key header
    if (key == nil) return(nil);
    
    unsigned long len = key.length;
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)key.bytes;
    unsigned int  idx    = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

SecKeyRef _ks_RSA_addPublicKey(NSString *key) {
    NSData *data = _ks_RSA_stripPublicKeyHeader([NSData.alloc initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters]);
    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:tag.UTF8String length:tag.length];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [NSMutableDictionary dictionaryWithCapacity:8];
    [publicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [publicKey setObject:@YES forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if (status != noErr) return nil;
    return keyRef;
}

NSData *_ks_RSA_encryptRef(NSData *data, SecKeyRef keyRef) {
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = NSMutableData.data;
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef, kSecPaddingPKCS1, srcbuf + idx, data_len, outbuf, &outlen);
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", status);
            ret = nil;
            break;
        } else {
            [ret appendBytes:outbuf length:outlen];
        }
    }
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

NSData *_ks_RSAEncrypt(NSData *data, NSString *key) {
    if (data == nil || key == nil || data.length == 0 || key.length == 0) return nil;
    SecKeyRef keyRef = _ks_RSA_addPublicKey(key);
    if (keyRef == NULL) return nil;
    return _ks_RSA_encryptRef(data, keyRef);
}
