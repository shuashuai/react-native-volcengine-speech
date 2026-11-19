require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'react-native-volcengine-speech'
  s.version = package.fetch('version')
  s.summary = 'React Native bridge for Volcengine Speech SDK'
  s.homepage = 'https://www.volcengine.com/'
  s.license = { :type => 'Proprietary' }
  s.author = 'code_shuai'
  s.source = { :path => '.' }
  s.platform = :ios, '15.1'
  s.requires_arc = true
  s.source_files = 'ios/**/*.{h,m,mm}'
  s.dependency 'React-Core'
  s.dependency 'SpeechEngineToB', '= 0.0.15.0'
end
