# Uncomment the next line to define a global platform for your project
platform :ios, '15.2'

target 'TRIPLE' do
  use_frameworks!
  use_modular_headers!

  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'GooglePlacesSwift'
  pod 'RiveRuntime'
  pod 'GoogleSignIn'
  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
end

