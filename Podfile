# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

project 'Commun.xcodeproj'
project 'cyberSwift/CyberSwift.xcodeproj'

def common_pods
  pod 'RxDataSources', '~> 3.0'
  pod 'Crashlytics'
  pod 'Amplitude-iOS'
end

def extensions_pods
    pod 'RxSwift'
    pod 'RxCocoa'
end

def common_pods_commun
  common_pods
  extensions_pods
  
  pod 'Fabric'
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'AppsFlyerFramework'
  
  pod 'PureLayout'
  pod 'Alamofire'
  pod 'SDWebImage'
  pod 'SDWebImageWebPCoder'
  pod 'Action'
  pod 'SwiftyGif', :git => "https://github.com/communcom/SwiftyGif.git"
  
  pod "InitialsImageView"
  
  pod 'SwifterSwift/SwiftStdlib', :git => "https://github.com/communcom/SwifterSwift.git"   # Standard Library Extensions
  pod 'SwifterSwift/Foundation', :git => "https://github.com/communcom/SwifterSwift.git"    # Foundation Extensions
  pod 'SwifterSwift/UIKit', :git => "https://github.com/communcom/SwifterSwift.git"         # UIKit Extensions
  
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'TLPhotoPicker'
  
  pod 'PinCodeInputView'
  pod 'PhoneNumberKit', '~> 2.6'
  
  pod 'ASSpinnerView'
  
  pod 'ListPlaceholder'
  
  pod 'QRCodeReaderViewController', '~> 4.0.2'
  
  pod 'THPinViewController', :git => "https://github.com/communcom/THPinViewController.git", :branch => "commun"
  
  pod 'ImageViewer.swift', :git => "https://github.com/communcom/ImageViewer.swift.git"
  pod 'SDURLCache', '~> 1.3'
  pod 'UITextView+Placeholder'
  
  pod 'SubviewAttachingTextView', :git => "https://github.com/communcom/SubviewAttachingTextView.git"
  
  pod "ReCaptcha"
  pod 'SwiftLint'
  pod 'CircularCarousel'
  pod 'NotificationView'
  
  pod "SwipeTransition"
  pod "SwipeTransitionAutoSwipeBack"
  pod "SwipeTransitionAutoSwipeToDismiss"

  #Social Login
  pod 'FBSDKLoginKit', '6.0.0'
  pod 'FBSDKCoreKit', '6.0.0'
  pod 'GoogleSignIn', '5.0.2'

end

def cyberswift_common_pods
  common_pods
  # EOS framework
  pod 'eosswift', :git => "git@github.com:communcom/eos-swift.git"
  
  pod 'Checksum'
  pod 'Locksmith'
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

target 'CommunShare' do
  project 'Commun.xcodeproj'
  extensions_pods

  
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
