platform :ios, '8.0'
use_frameworks!

target 'Upupu' do
  pod 'Dropbox-iOS-SDK', '~> 1.3.13'
  pod 'InAppSettingsKit', '~> 2.6'
  pod 'MBProgressHUD', '~> 0.9.1'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-Upupu/Pods-Upupu-Acknowledgements.plist', 'Upupu/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
