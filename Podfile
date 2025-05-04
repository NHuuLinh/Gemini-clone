# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

target 'Geminize' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Kingfisher'
  pod 'Alamofire'
  pod 'RealmSwift'
  pod 'MessageKit', '~> 3.8.0'
  pod 'KeychainSwift'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'RealmSwift'

  # Pods for Geminize

  target 'GeminizeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GeminizeUITests' do
    # Pods for testing
  end

end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
               end
          end
   end
end
