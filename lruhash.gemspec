require File.expand_path('../lib/lruhash/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name     = "lruhash"
  gem.version  = "1.0.1"
  gem.date     = "2009-04-11"
  gem.summary  = "A hash class with LRU semantics"
  gem.homepage = "http://github.com/invoca/lrudhash"
  gem.description = "A hash class that is limited in size and discards old entries based on LRU - forked from http://github.com/oldmoe/lrudhash"

  gem.authors  = ["Bob Smith"]
  gem.email    = "bob@invoca.com"
  gem.platform = Gem::Platform::RUBY

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/.*\.rb})

  gem.rdoc_options = ["--main", "README"]
  gem.extra_rdoc_files = ["README.rdoc"]

  gem.add_development_dependency 'minitest' # Included in Ruby 1.9, but we want the latest.
  gem.add_development_dependency 'rake', '>=0.9'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'pry'

end

