require 'sinatra'
require 'faraday'
require 'we-call'

module FakeFbMarketingApi
  class Application < Sinatra::Base

    configure do

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
      @conn = We::Call::Connection.new(host: 'https://graph.facebook.com', timeout: 2) do |faraday|
        faraday.adapter :typhoeus
        faraday.response :logger do |logger|
          logger.filter(/(access_token=)(\w+)/, '\1[FILTERED]')
          logger.filter(/("access_token":)(.[^"]+)/, '\1[FILTERED]')
          logger.filter(/("token":)(.[^"]+)/, '\1[FILTERED]')
        end
      end
    end

    post '/v3.2/:business_id/adaccount' do
      content_type :json
      {
        end_advertiser_id: params[:end_advertiser_id],
        media_agency_id: params[:media_agency_id],
        business_id: params[:business_id],
        account_id: ENV['FACEBOOK_AD_ACCOUNT_ID'],
        id: "act_%{ENV['FACEBOOK_AD_ACCOUNT_ID']}",
        partner_id: 'NONE'
      }.to_json
    end

    post '/v3.0/:ad_account_id/assigned_users' do
      content_type :json
      {
        success: true
      }.to_json
    end

    post '/v3.2/:business_id/businessprojects' do
      content_type :json
      {
        id: ENV['PROJECT_ID']
      }.to_json
    end

    post '/v3.2/:ad_account_id/campaigns' do
      content_type :json
      case params[:objective]
      when 'BRAND_AWARENESS'
        {
          id: ENV['BRAND_AWARENESS_CAMPAIGN_ID']
        }.to_json
      when 'LINK_CLICKS'
        {
          id: ENV['LINK_CLICKS_CAMPAIGN_ID']
        }.to_json
      when 'VIDEO_VIEWS'
        {
          id: ENV['VIDEO_VIEWS_CAMPAIGN_ID']
        }.to_json
      when 'REACH'
        {
          id: ENV['REACH_CAMPAIGN_ID']
        }.to_json
      when 'POST_ENGAGEMENT'
        {
          id: ENV['POST_ENGAGEMENT_CAMPAIGN_ID']
        }.to_json
      when 'PAGE_LIKES'
        {
          id: ENV['PAGE_LIKES_CAMPAIGN_ID']
        }.to_json
      end
    end

    get '/v3.2/:graph_id/*' do
      content_type :json
      proxy_to_fb(request, response)
    end

    post '/v3.2/*' do
      content_type :json
      return proxy_post_to_fb(request, response)
    end

    get '/v3.2/*' do
      proxy_to_fb(request, response)
    end

    def proxy_to_fb(request, response)
      resp = @conn.get("#{request.path}?#{request.query_string}") do |req|
        request.params.each do |key, value|
          req.params[key] = value
        end
      end
      headers = resp.headers.select { |header, value| value != 'keep-alive' && value != 'chunked'  }
      [resp.status, headers, resp.body]
    end

    def proxy_post_to_fb(request, response)
      resp = @conn.post("#{request.path}?#{request.query_string}") do |req|
        request.params.each do |key, value|
          req.params[key] = value
        end
      end
      headers = resp.headers.select { |header, value| value != 'keep-alive' && value != 'chunked'  }
      [resp.status, headers, resp.body]
    end
  end
end
