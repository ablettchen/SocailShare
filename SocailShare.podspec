#
# Be sure to run `pod lib lint SocailShare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SocailShare'
  s.version          = '0.0.1'
  s.summary          = 'socail share'
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
                         DESC

  s.homepage         = 'https://github.com/ablettchen/SocailShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ablett' => 'ablettchen@gmail.com' }
  s.source           = { :git => 'https://github.com/ablettchen/SocailShare.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ablettchen/'
  s.platform         = :ios, "9.0"
  s.source_files     = 'SocailShare/Classes/**/*.{h,m,swift}'
  s.requires_arc     = true
  s.swift_version   = '5.1'
  
  # 微信SDK需要设置如下
  s.vendored_libraries   = "SocailShare/Classes/**/*.{a}"
  s.framework            = "WebKit"
  s.static_framework     = true
  s.user_target_xcconfig = {'OTHER_LDFLAGS' => '-lstdc++ -ObjC'}
  
  s.dependency 'SnapKit'
  s.dependency 'ATCategories'

end
