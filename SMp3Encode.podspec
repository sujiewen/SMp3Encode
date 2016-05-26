
Pod::Spec.new do |s|
  s.name             = 'SMp3Encode'
  s.version          = '0.0.1'
  s.summary          = 'mp3 边录边保存'

  s.description      = <<-DESC
mp3 录制和转换，边录边保存
                       DESC

  s.homepage         = 'https://github.com/sujiewen/SMp3Encode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sujiewen' => 'sujiewen@qq.com' }
  s.source           = { :git => 'https://github.com/sujiewen/SMp3Encode.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'SMp3Encode/Classes/**/*.{h,m}'
  s.public_header_files = 'SMp3Encode/Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/SMp3Encode/Lame"' }
end
