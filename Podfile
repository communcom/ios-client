# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

project 'Commun.xcodeproj'
project 'cyberSwift/CyberSwift.xcodeproj'

def common_pods
  pod 'RxDataSources', '~> 3.0'
end

def common_pods_commun
  common_pods
  
  pod 'SwiftLint'

  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
  pod 'Alamofire'
  pod 'Swinject'
  pod 'SDWebImage'
  pod 'SDWebImageWebPCoder'
  pod 'Action'
  pod 'DateToolsSwift'
  pod 'SwiftyGif'
  
  pod "InitialsImageView"
  
  pod 'SwifterSwift/SwiftStdlib'   # Standard Library Extensions
  pod 'SwifterSwift/Foundation'    # Foundation Extensions
  pod 'SwifterSwift/UIKit'         # UIKit Extensions
  
  pod 'Segmentio'
  
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'TLPhotoPicker'
  
  pod 'PinCodeInputView'
  pod 'PhoneNumberKit', '~> 2.6'
  
  pod 'ASSpinnerView'
  
  pod 'ListPlaceholder'
  
  pod 'QRCodeReaderViewController', '~> 4.0.2'
  
  pod 'THPinViewController', :git => "https://github.com/bigearsenal/THPinViewController.git", :branch => "commun"
  
  pod 'AppImageViewer'
  pod 'SDURLCache', '~> 1.3'
  pod 'UITextView+Placeholder'
  
  pod "ESPullToRefresh"
  pod 'PureLayout'
  pod 'SubviewAttachingTextView', :git => "https://github.com/communcom/SubviewAttachingTextView.git"
  
  pod "ReCaptcha"

end

def cyberswift_common_pods
  common_pods
  # EOS framework
  pod 'eosswift', :git => "git@github.com:communcom/eos-swift.git"
  
  pod 'RxSwift'
  pod 'RxCocoa'
  
  pod 'Checksum'
  pod 'Locksmith'
  pod 'SwiftTheme'
  pod 'CryptoSwift'
  pod 'secp256k1.swift'
  pod 'Localize-Swift', '~> 2.0'
  
  # Websockets in swift for iOS and OSX
  #  pod 'Starscream', '~> 3.0'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'Starscream'
  pod 'ReachabilitySwift', '~> 4.3.1'
  
  # GoloCrypto
  pod 'GoloCrypto', :git => "git@github.com:communcom/GoloGrypto.git"
end

target 'Commun' do

  project 'Commun.xcodeproj'
  common_pods_commun
  cyberswift_common_pods
  

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

  project 'Commun.xcodeproj'
  common_pods_commun
  cyberswift_common_pods

end

target 'CyberSwift' do

  workspace 'cyberSwift/CyberSwift.xcworkspace'
  cyberswift_common_pods

end

target 'CyberSwiftTests' do

  workspace 'cyberSwift/CyberSwift.xcworkspace'
  cyberswift_common_pods

end
