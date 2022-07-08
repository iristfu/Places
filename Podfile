# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

target 'Places' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Places
  pod 'Parse'
  pod 'ParseUI'
  pod 'DateTools'
  pod 'SVPullToRefresh'
  pod 'MBProgressHUD'
  pod 'AFNetworking'
  pod 'BDBOAuth1Manager'
  pod 'RSKPlaceholderTextView'
  pod 'GooglePlaces', '7.0.0'

  target 'PlacesTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PlacesUITests' do
    # Pods for testing
  end

end
