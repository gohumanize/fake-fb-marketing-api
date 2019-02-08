# frozen_string_literal: true

require 'bundler/setup'
require 'fake_fb_marketing_api'
require 'rspec'
require 'rack/test'
require 'pry'
require 'fake_fb_marketing_api/application'
require 'faker'
require 'webmock'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods

  def app
    described_class
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
