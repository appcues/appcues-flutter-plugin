Pod::Spec.new do |s|
  s.name = 'appcues_flutter'
  s.version = '3.1.3'
  s.summary = 'Plugin package to bridge the native Appcues iOS SDK in a Flutter application.'
  s.description = <<-DESC
A plugin package for sending user properties and events to the Appcues API and retrieving and rendering Appcues content based on those properties and events.
                       DESC
  s.homepage = 'https://github.com/appcues/appcues-flutter-plugin'
  s.license = { :type => 'MIT', :file => '../LICENSE' }
  s.author = { 'Appcues' => 'mobile@appcues.com' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Appcues', '~> 3.1.2'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
