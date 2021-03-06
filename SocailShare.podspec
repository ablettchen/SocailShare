#
# Be sure to run `pod lib lint SocailShare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    
  s.name             = 'SocailShare'
  s.version          = '0.1.4'
  s.summary          = '社会化分享'
  s.homepage         = 'https://github.com/ablettchen/SocailShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ablett' => 'ablettchen@gmail.com' }
  s.source           = { :git => 'https://github.com/ablettchen/SocailShare.git', :tag => s.version.to_s }
  s.platform         = :ios, "10.0"
  s.source_files     = 'SocailShare/Classes/**/*.{h,swift,framework}'
  s.requires_arc     = true
  s.swift_version   = '5.2'
  

  s.vendored_libraries   = "SocailShare/Classes/**/*.{a}"
  s.vendored_frameworks  = 'SocailShare/Classes/**/*.framework'
  s.framework            = "WebKit", "Security", "SystemConfiguration", "CoreTelephony"
  s.static_framework     = true
  s.pod_target_xcconfig  = {'ENABLE_BITCODE' => 'NO', 'VALID_ARCHS' => 'x86_64 armv7 arm64'}
  s.user_target_xcconfig = {'OTHER_LDFLAGS' => '-lstdc++ -ObjC'}
  s.libraries = 'z', 'sqlite3', 'stdc++'

  s.dependency 'SnapKit'
  s.dependency 'ATCategories'
  s.dependency 'ATLoadView'
  s.dependency 'ATToast'
  s.dependency 'SDWebImage'

end
