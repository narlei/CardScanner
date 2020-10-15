#
# Be sure to run `pod lib lint CardScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CardScanner'
  s.version          = '0.1.2'
  s.summary          = 'A credit card scanner.'


  s.description      = <<-DESC
  A simple class to scan a credit card and get: number, date and cvv.
                       DESC

  s.homepage         = 'https://github.com/narlei/CardScanner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Narlei Moreira' => 'narlei.guitar@gmail.com' }
  s.source           = { :git => 'https://github.com/narlei/CardScanner.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/narleimoreira'

  s.ios.deployment_target = '13.0'
  s.swift_versions   = '5.0'
  s.source_files = 'CardScanner/Classes/**/*'
  
  
  # s.resource_bundles = {
  #   'CardScanner' => ['CardScanner/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
