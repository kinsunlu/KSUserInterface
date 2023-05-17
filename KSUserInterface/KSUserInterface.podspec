#
#  Be sure to run `pod spec lint KSUserInterface.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "KSUserInterface"
  spec.version      = "1.0.0"
  spec.summary      = "KSUserInterface"
  spec.description  = "KSUI库"
  spec.source       = { :path => "./" }

  spec.homepage     = "http://www.github.com/kinsunlu"
  spec.author       = { "kinsun" => "kinsunlu@sina.com" }
  
  spec.ios.deployment_target = "10.0"
  spec.requires_arc = true
  spec.pod_target_xcconfig = {"PRODUCT_BUNDLE_IDENTIFIER" => "com.kinsun.userinterface"}
  spec.static_framework = true
  spec.module_map = 'module.modulemap'
  
  spec.default_subspec = 'Main'
  
#  spec.subspec 'Authority' do |au|
#    au.source_files = 'KSUserInterface/Authority/**/*.{h,m}'
#  end

  spec.subspec 'Main' do |ma|
    ma.source_files = 'KSUserInterface/KSUserInterface.h', 'KSUserInterface/BaseView/**/*.{h,m}'
    ma.resources    = "KSUserInterface/KSUserInterface.bundle"
    ma.frameworks = "UIKit"
  end
  
  spec.subspec 'BaseWebView' do |bw|
    bw.source_files = 'KSUserInterface/BaseWebView/**/*.{h,m}'
    bw.frameworks = "WebKit"
    bw.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'Alert' do |at|
    at.source_files = 'KSUserInterface/Alert/**/*.{h,m}'
    at.dependency 'KSUserInterface/Main'
  end
    
  spec.subspec 'BannerView' do |bv|
    bv.source_files = 'KSUserInterface/Plugin/KSBannerView/**/*.{h,m}'
    bv.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'Button' do |btn|
    btn.source_files = 'KSUserInterface/Plugin/KSButton/**/*.{h,m}'
    btn.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'DialogView' do |dv|
    dv.source_files = 'KSUserInterface/Plugin/KSDialogView/**/*.{h,m}'
    dv.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'MediaViewer' do |mv|
    mv.source_files = 'KSUserInterface/Plugin/KSMediaViewer/**/*.{h,m}'
    mv.frameworks = "CoreServices"
    mv.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'ImagePicker' do |ip|
    ip.source_files = 'KSUserInterface/Plugin/KSImagePicker/**/*.{h,m}'
    ip.frameworks = "CoreServices"
    ip.dependency 'KSUserInterface/Button'
    ip.dependency 'KSUserInterface/MediaViewer'
  end
  
  spec.subspec 'ImageView' do |iv|
    iv.source_files = 'KSUserInterface/Plugin/KSImageView/**/*.{h,m}'
    iv.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'PageControl' do |pc|
    pc.source_files = 'KSUserInterface/Plugin/KSPageControl/**/*.{h,m}'
    pc.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'StackView' do |sv|
    sv.source_files = 'KSUserInterface/Plugin/KSStackView/**/*.{h,m}'
    sv.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'SegmentedControl' do |sc|
    sc.source_files = 'KSUserInterface/Plugin/KSSegmentedControl/**/*.{h,m}'
    sc.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'VideoPlayer' do |vp|
    vp.source_files = 'KSUserInterface/Plugin/KSVideoPlayer/**/*.{h,m}'
    vp.frameworks = "QuartzCore", "CoreMedia", "AVFoundation"
    vp.dependency 'KSUserInterface/Main'
  end
  
  spec.subspec 'ViewPager' do |vpr|
    vpr.source_files = 'KSUserInterface/Plugin/KSViewPager/**/*.{h,m}'
    vpr.dependency 'KSUserInterface/Main'
  end
    
  spec.dependency 'MJRefresh'
  spec.dependency 'KSFoundation'
  
end
