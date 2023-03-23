#
#  Be sure to run `pod spec lint DNAdSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "KSFoundation"
  spec.version      = "1.0.0"
  spec.summary      = "KSFoundation"
  spec.description  = "基础库，提供网络、设备信息收集、钥匙串存储、数据归档等能力"
  
  spec.source       = { :path => "./" }

  spec.homepage     = "http://www.github.com/kinsunlu"
  spec.author       = { "Kinsun" => "kinsunlu@sina.com" }
  
  spec.ios.deployment_target = "9.0"
  spec.requires_arc = true
  spec.pod_target_xcconfig = {"PRODUCT_BUNDLE_IDENTIFIER" => "com.kinsun.foundation"}
  spec.static_framework = true
  spec.module_map = 'module.modulemap'
  
  spec.source_files = 'KSFoundation/KSFoundation.h'
  
  spec.subspec 'ArchiveTools' do |ar|
    ar.source_files = 'KSFoundation/ArchiveTools/**/*.{h,m}'
    ar.frameworks = "UIKit"
  end
  
  spec.subspec 'Device' do |de|
    de.source_files = 'KSFoundation/Device/**/*.{h,m}'
    de.frameworks = "SystemConfiguration", "UIKit", "WebKit", "CoreLocation", "CoreTelephony", "AdSupport"
    de.weak_frameworks = "AppTrackingTransparency"
    de.private_header_files = 'KSFoundation/Device/_KSReachability.h'
  end
  
  spec.subspec 'Misc' do |mi|
    mi.source_files = 'KSFoundation/Misc/**/*.{h,m}'
    mi.frameworks = "Foundation"
  end
  
  spec.subspec 'Networking' do |ne|
    ne.source_files = 'KSFoundation/Networking/**/*.{h,m}'
    ne.frameworks = "Foundation"
  end
end
