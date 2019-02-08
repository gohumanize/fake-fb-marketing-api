# frozen_string_literal: true

require 'rack/builder'

require_relative './versions/v3_2'
require_relative './versions/v3_0'

module FakeFbMarketingApi
  class Application
    VERSIONS = [
      FakeFbMarketingApi::Versions::V32,
      FakeFbMarketingApi::Versions::V30
    ].freeze

    attr_reader :app

    def initialize(_params = {})
      @app = begin
        Rack::Builder.new do
          # run VERSIONS.first
          VERSIONS.each do |e|
            map "/#{e.namespace}" do
              run e
            end
          end
        end
      end
    end

    def call(env)
      @app.call(env)
    end
  end
end
