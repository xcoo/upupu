platform :ios, '9.0'
use_frameworks!

target 'Upupu' do
  pod 'Alamofire', '~> 4.0'
  pod 'Cartography', '~> 1.1.0'
  pod 'InAppSettingsKit', '~> 2.8'
  pod 'MBProgressHUD', '~> 1.0.0'
  pod 'SwiftyDropbox', '~> 4.1.0'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-Upupu/Pods-Upupu-Acknowledgements.plist',
                 'Upupu/Settings.bundle/Acknowledgements.plist',
                 :remove_destination => true)
end
