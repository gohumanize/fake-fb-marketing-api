
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fake_fb_marketing_api/version"

Gem::Specification.new do |spec|
  spec.name          = 'fake_fb_marketing_api'
  spec.version       = FakeFbMarketingApi::VERSION
  spec.authors       = ["Mike Menne"]
  spec.email         = ["mike@humanagency.org"]

  spec.summary       = 'Provides a stubbed interface for select Facebook Marketing API endpoints'
  spec.description   = 'The key purpose of this gem is to allow developers the ability to stub the endpoints related the the Facebook Business API.  Commands such as creating ad accounts can not be reversed and count against quota.'
  spec.homepage      = "https://humanagency.org/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    #spec.metadata["homepage_uri"] = spec.homepage
    #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency 'capybara_discoball'
  spec.add_development_dependency "faker", "~> 1.9"
  spec.add_development_dependency 'faraday'
  spec.add_development_dependency 'koala', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency "rack-test", "~> 1.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'webmock'
  spec.add_runtime_dependency "sinatra", "~> 2.0"
  spec.add_runtime_dependency 'we-call'

end
