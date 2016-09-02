platform :ios, '8.0'
use_frameworks!

target 'Upupu' do
  pod 'SwiftyDropbox', '~>3.2.0'
  pod 'InAppSettingsKit', '~> 2.7'
  pod 'MBProgressHUD', '~> 1.0.0'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-Upupu/Pods-Upupu-Acknowledgements.plist', 'Upupu/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
