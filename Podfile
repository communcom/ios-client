# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def common_pods
  pod 'Fabric'
  pod 'Crashlytics'
  
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
  pod 'CyberSwift', :git => "https://github.com/GolosChain/cyberSwift.git", :branch => "features/new_bc" # "https://github.com/Monserg/cyber-ios.git"
  
  pod 'Alamofire'
  pod 'Swinject'
  pod 'SDWebImage', '~> 4.0'
  pod 'Action'
  pod 'UIImageView-Letters'
  pod 'DateToolsSwift'
  
  pod 'UIImageView-Letters'
  
  pod 'SwifterSwift/SwiftStdlib'   # Standard Library Extensions
  pod 'SwifterSwift/Foundation'    # Foundation Extensions
  pod 'SwifterSwift/UIKit'         # UIKit Extensions
  
  pod 'Segmentio'
  
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'TLPhotoPicker'
  
  pod 'PinCodeInputView'
  pod 'PhoneNumberKit', '~> 2.6'
  
  pod 'RxDataSources', '~> 3.0'
  
  pod 'ASSpinnerView'
  
  pod 'ListPlaceholder'
  
  pod 'DZNEmptyDataSet'
  
  pod 'TTTAttributedLabel'
  pod 'QRCodeReaderViewController', '~> 4.0.2'
  
  pod 'THPinViewController', :git => "https://github.com/bigearsenal/THPinViewController.git", :branch => "commun"
  
  pod 'AppImageViewer'
  pod 'SwiftLinkPreview', '~> 3.0.1'
  pod 'Down'
  pod 'SDURLCache', '~> 1.3'
  pod 'UITextView+Placeholder'
  
  pod "ESPullToRefresh"
  pod 'PureLayout'
end

target 'Commun' do
  common_pods
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['CyberSwift'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '5'
        end
      end
    end
  end
  
end

target 'CommunTests' do
  common_pods
end
