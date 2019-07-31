# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'Commun' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Fabric'
  pod 'Crashlytics'

  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
  pod 'CyberSwift', :git => "https://github.com/GolosChain/cyberSwift.git" # "https://github.com/Monserg/cyber-ios.git"
  
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
  
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'TLPhotoPicker'
  
  pod 'PinCodeInputView'
  pod 'PhoneNumberKit', '~> 2.6'
  
  pod 'RxDataSources', '~> 3.0'
  
  pod 'ASSpinnerView'

  pod 'ListPlaceholder'
  
  pod 'DZNEmptyDataSet'
  pod 'ReachabilitySwift'
  
  pod 'TTTAttributedLabel'
  pod 'QRCodeReaderViewController', '~> 4.0.2'
  
  pod 'THPinViewController', :git => "https://github.com/bigearsenal/THPinViewController.git", :branch => "commun"
  
  pod 'AppImageViewer'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['PDFReader'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4'
        end
      end
    end
  end
  
end
