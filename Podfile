# Uncomment the next line to define a global platform for your project
DEFAULT_SWIFT_VERSION = '5.0'
DEFAULT_PLATFORM_VERSION = '12.0'

platform :ios, DEFAULT_PLATFORM_VERSION
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

def firebase_pods
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Performance'
  pod 'Firebase/Crashlytics'
end

def util_pods
  pod 'Moya', '~> 15.0'
  pod 'KeychainSwift'
  pod 'GoogleMaps'
  pod 'Google-Maps-iOS-Utils'
  pod 'GooglePlaces'
  pod 'RealmSwift'
  pod 'Solar'
  pod 'SQLite.swift'
  pod 'SwiftLint'
end

def ui_pods
  pod 'Kingfisher'
  pod 'Toast-Swift'
  pod 'SpringIndicator'
  pod 'SwiftIcons'
  pod 'EasyTipView'
  pod 'XLPagerTabStrip'
  pod 'lottie-ios'
  pod 'MMBAlertsPickers', :git => 'https://github.com/appsstudioio/MMBAlertsPickers.git', :branch => 'master'
end

def ad_pods
  pod 'AdFitSDK'
end

target 'TakeCare' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # ignore all warnings from all pods
  inhibit_all_warnings!
  
  # Pods for TakeCare
  firebase_pods
  util_pods
  ui_pods
  ad_pods
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
         config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEFAULT_PLATFORM_VERSION
         config.build_settings['SWIFT_VERSION'] = DEFAULT_SWIFT_VERSION
     end
 end
end
