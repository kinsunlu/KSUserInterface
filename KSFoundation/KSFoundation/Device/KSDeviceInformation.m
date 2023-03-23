//
//  KSDeviceInformation.m
//  KSFoundation
//
//  Created by Kinsun on 2020/12/7.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSDeviceInformation.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KSArchiveTools.h"
#import "KSDeviceTools.h"

static NSString * const _ks_K_USER_AGENT_ARCHIVE_KEY = @"com.kinsun.foundation.useragent.archive.key";

NSNotificationName const KSDeviceInformationNeedUpdateNotification = @"KSDeviceInformationNeedUpdateNotification";
NSString * const KSDeviceInformationUpdateKey = @"KSDeviceInformationUpdateKey";

@interface KSDeviceInformation () <CLLocationManagerDelegate>

@end

@implementation KSDeviceInformation {
    WKWebView *_webView;
    CLLocationManager *_locationManager;
}

+ (KSDeviceInformation *)device {
    static KSDeviceInformation *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] _initConfig];
    });
    return _instance;
}

- (instancetype)_initConfig {
    if (self = [super init]) {
        _imsi = _ks_getIMSI();
        NSString *ua = [KSArchiveTools.globalArchiveTools objectForKey:_ks_K_USER_AGENT_ARCHIVE_KEY];
        if (ua != nil && ua.length > 0) {
            _ua = ua;
        }
        _model = _ks_getDeviceModel() ?: @"";
        UIDevice *currentDevice = UIDevice.currentDevice;
        _osv = currentDevice.systemVersion;
        _idfv = currentDevice.identifierForVendor.UUIDString;
        _ip = _ks_getDeviceIPAddress();
        _ipv6 = _ks_getNetworkIPAddress(false);
        _suuid = _ks_getUUID();
        _carrier = _ks_getCarrier();
        _lang = _ks_getCurrentLanguages();
        UIScreen *mainScreen = UIScreen.mainScreen;
        CGSize windowSize = mainScreen.bounds.size;
        CGFloat scale = mainScreen.scale;
        _screenWidth = scale * windowSize.width;
        _screeHeight = scale * windowSize.height;
        _pxratio = mainScreen.scale;
        [self _getUserAgent];
        [self _initializeLocationService];
        [self _applicationDidBecomeActiveNotification:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)_applicationDidBecomeActiveNotification:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    _ks_getIDFA(^(BOOL isRequest, NSString *idfa) {
        __strong typeof(weakSelf) self = weakSelf;
        self->_idfa = idfa;
        if (isRequest) {
            [self _postUpdateNotificationWithUpdate:KSDeviceInformationUpdateIDFA];
        }
    });
    if (notification != nil) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (instancetype)init {
    KSDeviceInformation *device = KSDeviceInformation.device;
    if (self = [super init]) {
        _imsi = device.imsi;
        _ua = device.ua;
        _model = device.model;
        _osv = device.osv;
        _idfa = device.idfa;
        _idfv = device.idfv;
        _ip = device.ip;
        _ipv6 = device.ipv6;
        _suuid = device.suuid;
        _carrier = device.carrier;
        _lang = device.lang;
        _screenWidth = device.screenWidth;
        _screeHeight = device.screeHeight;
        _pxratio = device.pxratio;
        _lat = device.lat;
        _lng = device.lng;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_deviceInformationNeedUpdateNotification:) name:KSDeviceInformationNeedUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    if (self != KSDeviceInformation.device) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:KSDeviceInformationNeedUpdateNotification object:nil];
    }
}

- (void)_deviceInformationNeedUpdateNotification:(NSNotification *)notification {
    KSDeviceInformationUpdate type = [[notification.userInfo objectForKey:KSDeviceInformationUpdateKey] integerValue];
    KSDeviceInformation *device = KSDeviceInformation.device;
    switch (type) {
        case KSDeviceInformationUpdateIDFA:
            _idfa = device.idfa;
            break;
        case KSDeviceInformationUpdateLocation: {
            _lng = device.lng;
            _lat = device.lat;
        }
            break;
        case KSDeviceInformationUpdateUserAgent:
            _ua = device.ua;
            break;
        default:
            break;
    }
    [self resetToDictionaryValueCache];
}

- (void)_initializeLocationService {
    void (^config)(CLLocationManager *) = ^(CLLocationManager *locationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
    };
    if (@available(iOS 14.0, *)) {
        CLLocationManager *locationManager = CLLocationManager.alloc.init;
        CLAuthorizationStatus status = locationManager.authorizationStatus;
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            locationManager.delegate = self;
            config(locationManager);
            _locationManager = locationManager;
        }
    } else {
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            CLLocationManager *locationManager = CLLocationManager.alloc.init;
            locationManager.delegate = self;
            config(locationManager);
            _locationManager = locationManager;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];
    _locationManager = nil;
    CLLocationCoordinate2D location = locations.firstObject.coordinate;
    _lat = location.latitude;
    _lng = location.longitude;
    [self _postUpdateNotificationWithUpdate:KSDeviceInformationUpdateLocation];
}

- (void)_postUpdateNotificationWithUpdate:(KSDeviceInformationUpdate)update {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf != nil) {
            [NSNotificationCenter.defaultCenter postNotificationName:KSDeviceInformationNeedUpdateNotification object:weakSelf userInfo:@{KSDeviceInformationUpdateKey: [NSNumber numberWithInteger:update]}];
        }
    });
}

- (NSInteger)connectionType {
    return _ks_GetNetworkType();
}

- (void)_getUserAgent {
    WKWebView *webview = WKWebView.alloc.init;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"about:black"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [webview loadRequest:request];
    @try {
        __weak typeof(self) weakSelf = self;
        [webview evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            [weakSelf _getUserAgentAfterWithResult:result];
        }];
        _webView = webview;
    } @catch (NSException *exception) { }
}

- (void)_getUserAgentAfterWithResult:(NSString *)ua {
    if (ua != nil && [ua isKindOfClass:NSString.class] && ![self->_ua isEqualToString:ua]) {
        _ua = ua;
        [KSArchiveTools.globalArchiveTools setObject:ua forKey:_ks_K_USER_AGENT_ARCHIVE_KEY];
        [self _postUpdateNotificationWithUpdate:KSDeviceInformationUpdateUserAgent];
    }
    _webView = nil;
}

- (NSInteger)orientation {
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        return 1;
    else return 2;
}

- (NSMutableDictionary<NSString *,id> *)toDictionaryValue {
    NSMutableDictionary<NSString *,id> *dictionary = super.toDictionaryValue;
    // 设备联网方式 0:无网络，1:wifi，2:2G，3:3G，4:4G，5:5G
    NSNumber *connectiontype = [NSNumber numberWithInteger:_ks_GetNetworkType()];
    [dictionary setObject:connectiontype forKey:@"connectiontype"];
    NSNumber *orientation = [dictionary objectForKey:@"orientation"];
    NSInteger k_orientation = self.orientation;
    if (orientation.integerValue != k_orientation) {
        [dictionary setObject:[NSNumber numberWithInteger:k_orientation] forKey:@"orientation"];
    }
    return dictionary;
}

@end

@implementation KSApplicationInformation

+ (KSApplicationInformation *)application {
    static KSApplicationInformation *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] _initConfig];
    });
    return _instance;
}

- (instancetype)_initConfig {
    if (self = [super init]) {
        NSBundle *mainBundle = NSBundle.mainBundle;
        NSDictionary<NSString *, id> *infoDictionary = mainBundle.infoDictionary;
        _name = [infoDictionary objectForKey:@"CFBundleDisplayName"] ?: @"";
        _bundle = mainBundle.bundleIdentifier;
        _version = [infoDictionary objectForKey:@"CFBundleShortVersionString"] ?: @"";
        _build = [infoDictionary objectForKey:@"CFBundleVersion"] ?: @"";
    }
    return self;
}

- (instancetype)init {
    KSApplicationInformation *application = KSApplicationInformation.application;
    if (self = [super init]) {
        _name = application.name;
        _bundle = application.bundle;
        _version = application.version;
        _build = application.build;
    }
    return self;
}

@end
