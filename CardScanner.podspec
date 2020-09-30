#
# Be sure to run `pod lib lint CardScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CardScanner'
  s.version          = '0.1.0'
  s.summary          = 'A credit card scanner.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

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

  s.source_files = 'CardScanner/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CardScanner' => ['CardScanner/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
