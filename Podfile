source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '6.0'

pod 'Dropbox-iOS-SDK', '~> 1.3.13'
pod 'InAppSettingsKit', '~> 2.6'
pod 'MBProgressHUD', '~> 0.9.1'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Upupu/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
