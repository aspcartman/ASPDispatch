Pod::Spec.new do |s| 
	s.name         = 'ASPDispatch'
	s.version      = '1.0.0'
	s.summary      = 'Allows writing asynchronous code synchronously.'
	s.license      = 'MIT'
	s.author = {
		'ASPCartman' => 'aspcartman@gmail.com'
	}
	s.description  = 'Coroutines-like dispatch with future and promises, happy living in the main thread and dispatch_queues.'

	s.requires_arc = true
  	s.ios.deployment_target = '7.0'
  	s.osx.deployment_target = '10.8'


	s.source = {
		:git => 'https://github.com/aspcartman/ASPDispatch.git',
		:tag => s.version.to_s
	}
	s.source_files = 'ASPDispatch/*.{h,m}'
end