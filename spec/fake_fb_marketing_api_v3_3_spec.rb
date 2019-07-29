# frozen_string_literal: true

require 'koala'
require 'capybara_discoball'

RSpec.describe FakeFbMarketingApi::Application do
  before { ENV['PROJECT_ID'] = Faker::Number.number(10) }
  before { ENV['BUSINESS_ID'] = Faker::Number.number(10) }
  before { ENV['FACEBOOK_AD_ACCOUNT_ID'] = Faker::Number.number(10) }
  before { ENV['FACEBOOK_AD_ACCOUNT_NAME'] = Faker::Seinfeld.character }
  before { ENV['BRAND_AWARENESS_CAMPAIGN_ID'] = Faker::Number.number(10) }
  before { ENV['LINK_CLICKS_CAMPAIGN_ID'] = Faker::Number.number(10) }
  before { ENV['VIDEO_VIEWS_CAMPAIGN_ID'] = Faker::Number.number(10) }
  before { ENV['CONVERSIONS_CAMPAIGN_ID'] = Faker::Number.number(10) }
  before { ENV['REACH_CAMPAIGN_ID'] = Faker::Number.number(10) }
  before { ENV['POST_ENGAGEMENT_CAMPAIGN_ID'] = Faker::Number.number(10) }
  before { ENV['PAGE_LIKES_CAMPAIGN_ID'] = Faker::Number.number(10) }
  before do
    FakeFbMarketingApi::FakeFacebook.setup
    WebMock.disable_net_connect!(allow: /127.0.0.1/)
    Capybara::Discoball.spin(FakeFbMarketingApi::Application) do |server|
      Koala.http_service.http_options = {
        use_ssl: false
      }
      Koala.configure do |config|
        config.api_version = 'v3.3'
        config.graph_server = server.url.gsub 'http://', ''
      end
    end
  end

  let(:access_token) { Faker::Number.number(20) }
  let(:graph) { Koala::Facebook::API.new(access_token) }

  it 'has a version number' do
    expect(FakeFbMarketingApi::VERSION).not_to be nil
  end

  describe 'GET /:business_id/owned_ad_acocunts' do
    it 'does not show any ad accounts until one is created' do
      response = graph.get_object("#{ENV['BUSINESS_ID']}/owned_ad_accounts", fields: 'id,name')

      expect(response).to eq([])
    end

    it 'returns a single ad account after one has been created' do
      end_advertiser_id = Faker::Number.number(10)
      media_agency_id = Faker::Number.number(10)
      name = Faker::Seinfeld.character
      response = graph.put_connections "#{ENV['BUSINESS_ID']}", 'adaccount',
        name: name,
        currency: 'USD', timezone_id: 6, end_advertiser_id: end_advertiser_id,
        media_agency_id: media_agency_id, partner: 'NONE'
      response = graph.get_object("#{ENV['BUSINESS_ID']}/owned_ad_accounts", fields: 'id,name')

      expect(response).to eq(
        [
          {
            'id' => ENV.fetch('FACEBOOK_AD_ACCOUNT_ID'),
            'name' => name
          }
        ]
      )
    end
  end

  describe 'POST /:business_id/adaccount' do
    context 'when creating an ad account' do
      it 'works' do
        end_advertiser_id = Faker::Number.number(10)
        media_agency_id = Faker::Number.number(10)
        response = graph.put_connections (ENV['BUSINESS_ID']).to_s, 'adaccount',
                                         name: 'Test Ad Account',
                                         currency: 'USD', timezone_id: 6, end_advertiser_id: end_advertiser_id,
                                         media_agency_id: media_agency_id, partner: 'NONE'

        expect(response).to include
        {
          'business_id' => ENV['BUSINESS_ID'],
          'account_id' => ENV['FACEBOOK_AD_ACCOUNT_ID'],
          'id' => "act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}",
          'end_advertiser_id' => end_advertiser_id,
          'media_agency_id' => media_agency_id,
          'partner_id' => 'NONE'
        }
      end
    end
  end

  describe 'POST /:project_id/adaccounts' do
    context 'when adding a user to an ad account' do
      it 'calls out to facebook' do
        project_id = Faker::Number.number(15).to_s
        fb_ad_account = ENV['FACEBOOK_AD_ACCOUNT_ID']
        stub_request(:post, "https://graph.facebook.com/v3.3/#{project_id}/adaccounts?access_token=#{access_token}&adaccount_id=#{fb_ad_account}")
          .with(
            headers: {
              'Expect' => '',
              'User-Agent' => 'fb-graph-proxy',
              'X-App-Env' => 'staging',
              'X-App-Name' => 'fb-graph-proxy'
            }
          ).to_return(status: 200, body: { 'success' => true }.to_json, headers: {})

        response = graph.put_connections(project_id, 'adaccounts', adaccount_id: fb_ad_account)

        expect(response).to eq('success' => true)
      end
    end
  end

  describe 'POST /:ad_account_id/assigned_users' do
    it 'passes makes a post to fb' do
      user_id = Faker::Number.number(14).to_s
      ad_account_id = Faker::Number.number(15).to_s
      stub_request(:post, "https://graph.facebook.com/v3.3/#{ad_account_id}/assigned_users?access_token=#{access_token}&tasks=ANALYZE,MANAGE,ADVERTISE&user=#{user_id}")
        .with(
          headers: {
            'Content-Length' => '0',
            'Expect' => '',
            'User-Agent' => 'fb-graph-proxy',
            'X-App-Env' => 'staging',
            'X-App-Name' => 'fb-graph-proxy'
          }
        )
        .to_return(status: 200, body: { 'success' => true }.to_json, headers: {})

      response = graph.put_connections(ad_account_id, 'assigned_users', user: user_id, tasks: %w[ANALYZE MANAGE ADVERTISE])

      expect(response).to eq 'success' => true
    end
  end

  describe 'POST /:business_id/businessprojects' do
    it 'passes a static project_id' do
      stub_request(:post, "https://graph.facebook.com/v3.3/#{ENV['BUSINESS_ID']}/businessprojects?access_token=#{access_token}&name=test_project")
        .to_return(status: 200, body: { 'id' => ENV['PROJECT_ID'] }.to_json, headers: {})

      result = graph.put_connections(ENV['BUSINESS_ID'], 'businessprojects', name: 'test_project')

      expect(result).to include 'id' => ENV['PROJECT_ID']
    end
  end

  describe 'POST /:ad_account_id/campaigns' do
    it 'works for brand awareness' do
      objective = 'BRAND_AWARENESS'

      campaign = graph.put_connections("act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}", 'campaigns', budget_rebalance_flag: false, name: "#{objective} Test Campaign", objective: objective, status: 'ACTIVE')

      expect(campaign).to eq 'id' => ENV['BRAND_AWARENESS_CAMPAIGN_ID']
    end

    it 'works for link clicks' do
      objective = 'LINK_CLICKS'

      campaign = graph.put_connections("act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}", 'campaigns', budget_rebalance_flag: false, name: "#{objective} Test Campaign", objective: objective, status: 'ACTIVE')

      expect(campaign).to eq 'id' => ENV['LINK_CLICKS_CAMPAIGN_ID']
    end

    it 'works for video views' do
      objective = 'VIDEO_VIEWS'

      campaign = graph.put_connections("act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}", 'campaigns', budget_rebalance_flag: false, name: "#{objective} Test Campaign", objective: objective, status: 'ACTIVE')

      expect(campaign).to eq 'id' => ENV['VIDEO_VIEWS_CAMPAIGN_ID']
    end

    it 'works for reach' do
      objective = 'REACH'

      campaign = graph.put_connections("act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}", 'campaigns', budget_rebalance_flag: false, name: "#{objective} Test Campaign", objective: objective, status: 'ACTIVE')

      expect(campaign).to eq 'id' => ENV['REACH_CAMPAIGN_ID']
    end

    it 'works for post engagement' do
      objective = 'POST_ENGAGEMENT'

      campaign = graph.put_connections("act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}", 'campaigns', budget_rebalance_flag: false, name: "#{objective} Test Campaign", objective: objective, status: 'ACTIVE')

      expect(campaign).to eq 'id' => ENV['POST_ENGAGEMENT_CAMPAIGN_ID']
    end

    it 'works for page likes' do
      objective = 'PAGE_LIKES'

      campaign = graph.put_connections("act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}", 'campaigns', budget_rebalance_flag: false, name: "#{objective} Test Campaign", objective: objective, status: 'ACTIVE')

      expect(campaign).to eq 'id' => ENV['PAGE_LIKES_CAMPAIGN_ID']
    end

    it 'works for conversions' do
      objective = 'CONVERSIONS'

      campaign = graph.put_connections("act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}", 'campaigns', budget_rebalance_flag: false, name: "#{objective} Test Campaign", objective: objective, status: 'ACTIVE')

      expect(campaign).to eq 'id' => ENV['CONVERSIONS_CAMPAIGN_ID']
    end
  end

  describe 'GET /:ad_account_id/campaigns' do
    context 'when no campaigns have been created' do
      it 'returns nothing' do
      end
    end
  end

  describe 'GET /:graph_id/insights' do
    it 'passes through insight requests' do
      graph_id = Faker::Number.number(10)
      stub_request(:get, "https://graph.facebook.com/v3.3/#{graph_id}/insights?access_token=#{access_token}&date_preset=lifetime&fields=ad_id")
        .to_return(status: 200, body: "{\"data\":[{\"ad_id\":\"#{graph_id}\",\"date_start\":\"2018-05-30\",\"date_stop\":\"2019-01-05\"}],\"paging\":{\"cursors\":{\"before\":\"MAZDZD\",\"after\":\"MAZDZD\"}}}", headers: {})

      ad_insights = graph.get_object("#{graph_id}/insights", fields: 'ad_id', date_preset: 'lifetime')

      expect(ad_insights.count).to eq 1
      expect(ad_insights.first['ad_id']).to eq graph_id
    end

    it 'returns headers of the api call' do
      graph_id = Faker::Number.number(10)
      headers = { 'etag' => '423144fb7fd642308ea9666e20cceb65ee4f6650' }
      stub_request(:get, "https://graph.facebook.com/v3.3/#{graph_id}/insights?access_token=#{access_token}&date_preset=lifetime&fields=ad_id")
        .to_return(status: 200, body: "{\"data\":[{\"ad_id\":\"#{graph_id}\",\"date_start\":\"2018-05-30\",\"date_stop\":\"2019-01-05\"}],\"paging\":{\"cursors\":{\"before\":\"MAZDZD\",\"after\":\"MAZDZD\"}}}", headers: headers)

      ad_insights = graph.get_object("#{graph_id}/insights", fields: 'ad_id', date_preset: 'lifetime')

      expect(ad_insights.headers).to include 'etag'
    end

    it 'returns the status of the api call' do
      graph_id = Faker::Number.number(10)
      headers = { 'etag' => '423144fb7fd642308ea9666e20cceb65ee4f6650' }
      stub_request(:get, "https://graph.facebook.com/v3.3/#{graph_id}/insights?access_token=#{access_token}&date_preset=lifetime&fields=ad_id")
        .to_return(status: 400, body: "{\"error\":{\"message\":\"(#100) date_preset must be \",\"type\":\"OAuthException\",\"code\":100,\"fbtrace_id\":\"GB8SawFk\/47\"}}", headers: headers)

      expect do
        graph.get_object("#{graph_id}/insights", fields: 'ad_id', date_preset: 'lifetime')
      end.to raise_error Koala::KoalaError
    end
  end

  describe 'POST / batch requests' do
    it 'passes through insight requests' do
      graph_id = Faker::Number.number(10)
      json = File.open("#{Dir.pwd}/spec/fb_batch_response.json").read
      json.gsub!('replace_ad_id', graph_id)
      stub_request(:post, "https://graph.facebook.com/v3.3/?access_token=#{access_token}&batch=%5B%7B%22method%22:%22get%22,%22relative_url%22:%22#{graph_id}/insights?date_preset=lifetime%26fields=ad_id%22%7D,%7B%22method%22:%22get%22,%22relative_url%22:%22#{graph_id}/insights?date_preset=lifetime%26fields=ad_id%22%7D%5D")
        .to_return(status: 200, body: json, headers: {})

      result = graph.batch do |batch|
        batch.get_object("#{graph_id}/insights", fields: 'ad_id', date_preset: 'lifetime')
        batch.get_object("#{graph_id}/insights", fields: 'ad_id', date_preset: 'lifetime')
      end

      expect(result.first.first).to include 'ad_id' => graph_id
    end

    it 'returns errror when they happen' do
      graph_id = Faker::Number.number(10)
      json = File.open("#{Dir.pwd}/spec/fb_batch_error_response.json").read
      json.gsub!('replace_ad_id', graph_id)
      stub_request(:post, "https://graph.facebook.com/v3.3/?access_token=#{access_token}&batch=%5B%7B%22method%22:%22get%22,%22relative_url%22:%22doesnotexist/insights?date_preset=lifetime%26fields=ad_id%22%7D,%7B%22method%22:%22get%22,%22relative_url%22:%22doesnotexist/insights?date_preset=lifetime%26fields=ad_id%22%7D%5D").
        # stub_request(:get, "https://graph.facebook.com/v3.0/?access_token=#{access_token}&batch=%5B%7B%22method%22:%22get%22,%22relative_url%22:%22#{graph_id}/insights?date_preset=lifetime%26fields=ad_id%22%7D%5D").
        to_return(status: 200, body: json)

      result = graph.batch do |batch|
        batch.get_object('doesnotexist/insights', fields: 'ad_id', date_preset: 'lifetime')
        batch.get_object('doesnotexist/insights', fields: 'ad_id', date_preset: 'lifetime')
      end

      expect(result[0].fb_error_code).to eq 803
      expect(result[1].fb_error_code).to eq 803
    end

    it 'passes headers through' do
      graph_id = Faker::Number.number(10)
      json = File.open("#{Dir.pwd}/spec/fb_batch_error_response.json").read
      json.gsub!('replace_ad_id', graph_id)
      stub_request(:post, "https://graph.facebook.com/v3.3/?access_token=#{access_token}&batch=%5B%7B%22method%22:%22get%22,%22relative_url%22:%22doesnotexist/insights?date_preset=lifetime%26fields=ad_id%22%7D,%7B%22method%22:%22get%22,%22relative_url%22:%22doesnotexist/insights?date_preset=lifetime%26fields=ad_id%22%7D%5D")
        .to_return(status: 200,
                   body: json,
                   headers: { 'Content-Type' => 'text/javascript; charset=UTF-8',
                              'Facebook-API-Version' => 'v3.3',
                              'X-App-Usage' => '{"call_count":0,"total_cputime":0,"total_time":0}',
                              'ETag' => '9d4067db4e21a79fc53d45e0f487e67c5c0b50a1',
                              'Access-Control-Allow-Origin' => '*',
                              'Cache-Control' => 'private, no-cache, no-store, must-revalidate',
                              'Vary' => 'Accept-Encoding',
                              'Expires' => 'Sat, 01 Jan 2000 00:00:00 GMT',
                              'X-Ad-Account-Usage' => '{"acc_id_util_pct":0}',
                              'Strict-Transport-Security' => 'max-age=15552000; preload',
                              'Transfer-Encoding' => 'chunked',
                              'Connection' => 'keep-alive',
                              'Pragma' => 'no-cache' })

      result = graph.batch do |batch|
        batch.get_object('doesnotexist/insights', fields: 'ad_id', date_preset: 'lifetime')
        batch.get_object('doesnotexist/insights', fields: 'ad_id', date_preset: 'lifetime')
      end

      expect(result).not_to be_nil
    end
  end

  describe 'POST /:ad_set_id' do
    it 'passes through requests to pause an ad' do
      graph_id = Faker::Number.number(10)
      stub_request(:post, "https://graph.facebook.com/v3.3/#{graph_id}/?access_token=#{access_token}&status=PAUSED")
        .to_return(status: 200, body: { success: true }.to_json, headers: {})

      result = graph.put_connections(graph_id, '', status: 'PAUSED')

      expect(result).to include 'success' => true
    end
  end

  describe 'GET /' do
    it 'gets graph objects' do
      graph_id = Faker::Number.number(10)
      json = File.open("#{Dir.pwd}/spec/fb_graph_object_response.json").read
      stub_request(:get, "https://graph.facebook.com/v3.3/?access_token=#{access_token}&fields=og_object%7Btitle,description,image%7D&id=https://fox2now.com/2018/04/02/5-myths-about-organ-donation/")
        .to_return(
          status: 200,
          body: json,
          headers:  { 'Vary' => 'Accept-Encoding',
                      'ETag' => '"90f0a9d85d04bf2760528d1f834dfa8444145dfb"',
                      'x-app-usage' => '{"call_count":0,"total_cputime":0,"total_time":0}',
                      'Content-Type' => 'application/json; charset=UTF-8',
                      'facebook-api-version' => 'v3.0',
                      'x-fb-rev' => '4669664',
                      'Access-Control-Allow-Origin' => '*',
                      'Cache-Control' => 'private, no-cache, no-store, must-revalidate',
                      'x-fb-trace-id' => 'HwmUZwadEmw',
                      'Expires' => 'Sat, 01 Jan 2000 00:00:00 GMT',
                      'Strict-Transport-Security' => 'max-age=15552000; preload',
                      'Pragma' => 'no-cache',
                      'X-FB-Debug' => 'ykeEji7+g4+BKuq0fR8pJC2k3egR1GLILfEN7eL2VcGOBqKa7u2nLHGrLOE5DfB6A7YlPTalEVgbAx8oDyIDnQ==',
                      'Date' => 'Tue, 08 Jan 2019 20:17:41 GMT',
                      'Transfer-Encoding' => 'chunked',
                      'Connection' => 'keep-alive' }
        )

      result = graph.get_object('', fields: 'og_object{title,description,image}', id: 'https://fox2now.com/2018/04/02/5-myths-about-organ-donation/')

      expect(result.dig('og_object')['title']).to eq '5 myths about organ donation'
    end
  end
end
