# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pixiv/version'

Gem::Specification.new do |gem|
  gem.name          = "pixiv"
  gem.version       = Pixiv::VERSION
  gem.authors       = ["Tomoki Aonuma"]
  gem.email         = ["uasi@uasi.jp"]
  gem.description   = %q{A client library for pixiv}
  gem.summary       = %q{A client library for pixiv}
  gem.homepage      = "https://github.com/uasi/pixiv"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'mechanize', '~> 2.0'

  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rspec-its', '~> 1.0'
  gem.add_development_dependency 'webmock', '~> 1.9'
end
