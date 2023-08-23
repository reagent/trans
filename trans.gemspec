lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trans/version'

Gem::Specification.new do |spec|
  spec.name          = 'trans'
  spec.version       = Trans::VERSION
  spec.authors       = ['Patrick Reagan']
  spec.email         = ['patrick@the-reagans.com']

  spec.homepage      = 'https://github.com/reagent/trans'
  spec.summary       = 'Tooling to help with transcoding video'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.2.2'

  spec.files = Dir['lib/**/*.rb', 'README.md']

  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
