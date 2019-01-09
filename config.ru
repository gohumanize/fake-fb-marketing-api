# config.ru

$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'fake_fb_marketing_api/application'

run FakeFbMarketingApi::Application
