source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def shared_dependencies
  pod 'JSONTools', :path => '.'
  pod 'KiteJSONValidator'
end

def extra_dependencies
  pod 'JSON-Schema-Test-Suite', '~> 1.1.2-Pod'
end

target "JSONTools" do
  platform :ios, '10.2'
  shared_dependencies
end

target "JSONToolsTests" do
  platform :ios, '10.2'
  shared_dependencies
  extra_dependencies
end

project 'JSONTools.xcodeproj'

