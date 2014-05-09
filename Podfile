xcodeproj 'JSONToolsTests.xcodeproj'
platform :ios, '7.0'
pod "JSONTools", path: '.'

target :JSONToolsTests, :exclusive => true do
  pod 'JSON-Schema-Test-Suite'
  pod 'KiteJSONValidator/KiteJSONResources'
end

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end

