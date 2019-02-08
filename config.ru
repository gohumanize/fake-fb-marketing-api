# frozen_string_literal: true

# config.ru

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'fake_fb_marketing_api/application'

$stdout.sync = true

run FakeFbMarketingApi::Application.new
