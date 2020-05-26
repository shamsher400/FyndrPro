# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Fyndr-Maldives' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Fyndr-Maldives
  pod 'KYDrawerController'
  
  # Pods for PodTest
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.13.4'
  # (Recommended) Pod for Google Analytics
  pod 'Firebase/Analytics'
  
  pod 'Kingfisher'
  pod 'CropViewController'
  pod 'Alamofire'
  pod 'CocoaLumberjack/Swift'
  
  pod 'XMPPFramework/Swift'
  pod 'Koloda'
  
  pod 'MessageKit', '3.0.0'
  pod 'SwiftyJSON', '4.0'
  
  pod 'NVActivityIndicatorView', '4.8.0'
  pod 'lottie-ios'
  pod 'DropDown', '2.3.4'
  
  pod 'ListPlaceholder'
  pod 'NotificationView'
  pod 'UICircularProgressRing'
  pod 'Instructions', '~> 1.3.1'
  
  pod 'GoogleSignIn'


  pod 'FacebookCore'
  pod 'FacebookLogin'
  
  pod 'SwiftyStoreKit'
  
  # OTP pin view 
  pod 'SVPinView', '~> 1.0'


  #  pod 'Firebase/Crash'
  #  pod 'Firebase/Core'
  
  #  pod 'Fabric', '~> 1.10.1'
  #  pod 'Crashlytics', '~> 3.13.1'
  
  #pod 'SwiftyCam'

  target 'Fyndr-MaldivesTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              if config.name == 'Debug'
                  config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
                  config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
              end
          end
      end
  end

end
