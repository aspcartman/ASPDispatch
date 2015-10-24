Pod::Spec.new do |s|
  s.name = 'ASPDispatch'
  s.version = '1.1.0'
  s.summary = 'Allows writing asynchronous code synchronously.'
  s.license = 'MIT'
  s.homepage = 'http://github.com/aspcartman/ASPDispatch'
  s.author = {
      'ASPCartman' => 'aspcartman@gmail.com'
  }
  s.description = 'Coroutines-like dispatch with future and promises, happy living in the main thread and dispatch_queues. Dynamic delegate as a bonus!'

  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'


  s.source = {
      :git => 'https://github.com/aspcartman/ASPDispatch.git',
      :tag => s.version.to_s
  }

  s.default_subspec = 'All'

  s.subspec 'All' do |ss|
    ss.dependency 'ASPDispatch/Core'
    ss.dependency 'ASPDispatch/DynamicDelegate'
    ss.ios.dependency 'ASPDispatch/UIKitAdditions'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'ASPDispatch/*.{h,m}'
  end

  s.subspec 'DynamicDelegate' do |ss|
    ss.source_files = 'ASPDynamicDelegate/*.{h,m}'
  end

  s.subspec 'UIKitAdditions' do |ss|
    platform = :ios
    ss.dependency 'ASPDispatch/Core'
    ss.dependency 'ASPDispatch/DynamicDelegate'
    ss.source_files = 'ASPDispatch-UIKit/*.{h,m}'
  end

end