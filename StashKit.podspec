Pod::Spec.new do |s|
  s.name         = "StashKit"
  s.version      = "0.0.1"
  s.summary      = "Wrapper for Atlassian Stash REST API."

  s.description  = s.summary

  s.license      = 'MIT'

  s.author       = { "Romain Pouclet" => "palleas@gmail.com" }

  s.source       = { :git => "git@bitbucket.org:Palleas/stashkit.git", :tag => "0.0.1" }

  s.source_files = 'StashKit', 'StashKit/**/*.{h,m}'
  s.dependency 'ReactiveCocoa', '~> 2.2'

end
