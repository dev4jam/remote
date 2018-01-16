Pod::Spec.new do |spec|
  spec.name         = "Remote"
  spec.version      = "1.0.0"
  spec.license      = {:type => "MIT", :file => "LICENSE", :text => "Copyright 2017 Dev4Jam"}
  spec.summary      = "Remote is a highly decoupled networking layer"
  spec.homepage     = "https://github.com/dev4jam/remote"
  spec.author       = { "Dev4Jam" => "dev4jam@gmail.com" }
  spec.social_media_url = 'http://twitter.com/dev4jam'
  spec.source       =  { :git => "https://github.com/dev4jam/remote.git", :branch => "master", :tag => s.version }
  spec.source_files = "Remote/**/*.{h, swift}"
  spec.ios.deployment_target = "10.3"
  spec.osx.deployment_target = "10.10"
  spec.watchos.deployment_target = "2.0"
  spec.tvos.deployment_target = "9.0"
  spec.requires_arc = true
  spec.platform     = :ios, "10.3"
  spec.frameworks   = "Foundation"
  spec.dependency "RxSwift"
  spec.dependency "Realm"
  spec.dependency "RealmSwift"
end

