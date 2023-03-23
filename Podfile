# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

workspace 'KSUserInterface.xcworkspace'

target 'KSUserInterfaceGuide' do
# Uncomment the next line if you're using Swift or would like to use dynamic frameworks
use_frameworks!
project 'KSUserInterfaceGuide/KSUserInterfaceGuide.xcodeproj'

pod 'MJRefresh', '3.7.5'
pod 'KSFoundation', :path => 'KSFoundation/'
pod 'KSUserInterface', :path => 'KSUserInterface/', :subspecs => ['Alert', 'BaseWebView', 'BannerView', 'Button','ImagePicker', 'MediaViewer', 'ImageView', 'StackView', 'SegmentedControl', 'ViewPager', 'DialogView', 'PageControl', 'VideoPlayer']

end
