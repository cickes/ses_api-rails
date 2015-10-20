# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ses_api/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "ses_api-rails"
  spec.version       = SesApi::Rails::VERSION
  spec.authors       = ["Chris Ickes"]
  spec.email         = ["chris@ickessoftware.com"]

  spec.summary       = %q{Basic Rails / Amazon SES API Integration.}
  spec.description   = %q{Rails / Amazon SES API integration for basic transactional email sending.}
  spec.homepage      = "https://github.com/cickes/ses_api-rails.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency 'mail'
  spec.add_dependency 'faraday'
end
