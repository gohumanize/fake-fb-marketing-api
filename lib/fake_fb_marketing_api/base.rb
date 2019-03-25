# frozen_string_literal: true

require 'sinatra'
require 'faraday'
require 'we-call'

require_relative './fake_facebook'

module FakeFbMarketingApi
  class Base < Sinatra::Base
    class << self
      attr_reader :namespace

      def set_namespace(name)
        @namespace = name
      end
    end

    configure do
      FakeFacebook.setup

      # setup WeCall
      We::Call.configure do |config|
        config.app_name = 'fb-graph-proxy'
        config.app_env = 'staging'
        config.detect_deprecations = false
      end
    end

    before do
      Faraday::Response::Logger::DEFAULT_OPTIONS[:headers] = false
      Faraday::Response::Logger::DEFAULT_OPTIONS[:bodies]  = true
      @conn = We::Call::Connection.new(host: 'https://graph.facebook.com', timeout: 30) do |faraday|
        faraday.adapter :typhoeus
        faraday.response :logger do |logger|
          logger.filter(/(access_token=)(\w+)/, '\1[FILTERED]')
          logger.filter(/("access_token":)(.[^"]+)/, '\1[FILTERED]')
          logger.filter(/("token":)(.[^"]+)/, '\1[FILTERED]')
        end
      end
    end

    private

    def proxy_get_to_fb(request, _response)
      resp = @conn.get("#{request.path}?#{request.query_string}") do |req|
        request.params.each do |key, value|
          req.params[key] = value
        end
      end
      headers = resp.headers.select { |_header, value| value != 'keep-alive' && value != 'chunked' }
      [resp.status, headers, resp.body]
    end

    def proxy_post_to_fb(request, _response)
      resp = @conn.post("#{request.path}?#{request.query_string}") do |req|
        request.params.each do |key, value|
          req.params[key] = value
        end
      end
      headers = resp.headers.select { |_header, value| value != 'keep-alive' && value != 'chunked' }
      [resp.status, headers, resp.body]
    end
  end
end
