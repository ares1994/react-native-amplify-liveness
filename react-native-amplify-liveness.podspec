require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'react-native-amplify-liveness'
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.homepage     = 'https://github.com/your-org/react-native-amplify-liveness'
  s.authors      = { 'author' => 'author@example.com' }
  s.source       = { :git => 'https://github.com/your-org/react-native-amplify-liveness.git', :tag => s.version.to_s }
  s.platforms    = { :ios => '14.0' } # Still requires iOS 14.0 platform constraint for linting

  # iOS files are excluded from CocoaPods autolinking because
  # Amplify UI Liveness requires SPM. See documentation for native integration guidelines.
  s.source_files = 'android/**/*.{java,kt}' # dummy to avoid warnings
  s.dependency 'React-Core'
  s.swift_version = '5.0'
end
