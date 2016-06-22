Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.name = "AwesomeSwiftSocks"
  s.summary = "A simple framework for handling sockets in Swift"
  s.requires_arc = true
  s.version = "0.0.1"
  s.license = { :type => "MIT" }
  s.author = { "Moray Baruh" => "contact@moraybaruh.com" }
  s.homepage = "https://github.com/moray95/AwesomeSwiftSocks"
  s.source = { :git => "https://github.com/moray95/AwesomeSwiftSocks.git", :tag => "0.0.1"}
  s.frameworks = "UIKit"
  s.source_files = "AwesomeSwiftSocks/**/*.{swift,h,c}"
  s.dependency "AwesomeSwiftSocksCore", "~> 0.1"
end