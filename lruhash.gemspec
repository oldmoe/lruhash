Gem::Specification.new do |s|
  s.name     = "lruhash"
  s.version  = "1.0"
  s.date     = "2009-04-11"
  s.summary  = "A hash class with LRU semantics"
  s.email    = "oldmoe@gmail.com"
  s.homepage = "http://github.com/oldmoe/lrudhash"
  s.description = "A hash class that is limited in size and discards old entries based on LRU"
  s.has_rdoc = true
  s.authors  = ["Muhammad A. Ali"]
  s.platform = Gem::Platform::RUBY
  s.files    = [ 
		"lruhash.gemspec", 
		"README",
		"lib/lruhash.rb"
	]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
end

