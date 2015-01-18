Pod::Spec.new do |s|
	s.name             = "SyncthingKit"
	s.version          = "0.1.0"
	s.summary          = "A simple framework to wrap Syncthing REST APIs"
	s.description      = <<-DESC
							A simple framework that wraps the Syncthing REST APIs. 
							DESC
	s.homepage         = "https://github.com/danilotorrisi/SyncthingKit"
	s.license          = 'MIT'
	s.author           = { "Danilo Torrisi" => "danilo.torrisi@me.com" }
	s.source           = { :git => "https://github.com/danilotorrisi/SyncthingKit.git", :tag => s.version.to_s }
	s.social_media_url = 'https://twitter.com/danilo_torrisi'

	s.platform 	= :ios, "8.0"
	s.requires_arc = true
	s.source_files = 'Sources'

	s.dependency 'Alamofire', '~> 1.1.3'
	s.dependency 'SwiftyJSON', '~> 2.1'
	s.dependency 'BrightFutures', '~> 1.0.0-beta.2'

end
