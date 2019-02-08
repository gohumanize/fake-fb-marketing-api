# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fake_fb_marketing_api/version'

Gem::Specification.new do |gem|
  gem.name          = 'fake_fb_marketing_api'
  gem.version       = FakeFbMarketingApi::VERSION
  gem.authors       = ['Mike Menne']
  gem.email         = ['mike@humanagency.org']

  gem.summary       = 'Provides a stubbed interface for select Facebook Marketing API endpoints'
  gem.description   = 'The key purpose of this gem is to allow developers the ability to stub the endpoints related the the Facebook Business API.  Commands such as creating ad accounts can not be reversed and count against quota.'
  gem.homepage      = 'https://humanagency.org/'
  gem.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if gem.respond_to?(:metadata)
    # gem.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    # gem.metadata["homepage_uri"] = gem.homepage
    # gem.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    # gem.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gem.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|gem|features)/}) }
  end
  gem.required_ruby_version = '>= 2.4.3'

  gem.add_development_dependency 'bundler', '~> 1.15'
  gem.add_development_dependency 'capybara_discoball'
  gem.add_development_dependency 'faker', '~> 1.9'
  gem.add_development_dependency 'faraday'
  gem.add_development_dependency 'koala', '~> 3.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-byebug'
  gem.add_development_dependency 'pry-stack_explorer'
  gem.add_development_dependency 'rack-test', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'webmock'
  gem.add_runtime_dependency 'sinatra', '~> 2.0'
  gem.add_runtime_dependency 'we-call', '~> 0.9'
end
