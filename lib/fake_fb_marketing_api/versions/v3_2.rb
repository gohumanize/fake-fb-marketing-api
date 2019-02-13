# frozen_string_literal: true

require_relative '../base'
require_relative '../fake_facebook'

module FakeFbMarketingApi
  module Versions
    class V32 < Base
      set_namespace 'v3.2'

      get '/:business_id/owned_ad_accounts' do
        content_type :json
        FakeFacebook.owned_ad_accounts.to_json
      end

      post '/:business_id/adaccount' do
        content_type :json
        FakeFacebook.add_owned_ad_account(
          {
            'name' => params[:name],
            'id' => ENV.fetch('FACEBOOK_AD_ACCOUNT_ID')
          }
        )
        {
          end_advertiser_id: params[:end_advertiser_id],
          media_agency_id: params[:media_agency_id],
          business_id: params[:business_id],
          account_id: ENV['FACEBOOK_AD_ACCOUNT_ID'],
          id: "act_#{ENV['FACEBOOK_AD_ACCOUNT_ID']}",
          partner_id: 'NONE'
        }.to_json
      end

      post '/:project_id/adaccounts' do
        content_type :json
        proxy_post_to_fb(request, response)
      end

      post '/:ad_account_id/assigned_users' do
        proxy_post_to_fb(request, response)
      end

      post '/:business_id/businessprojects' do
        proxy_post_to_fb(request, response)
      end

      post '/:ad_account_id/campaigns' do
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
        when 'CONVERSIONS_COUNT'
          {
            id: ENV['CONVERSIONS_COUNT_CAMPAIGN_ID']
          }.to_json
        when 'CONVERSIONS_FUNDRAISE'
          {
            id: ENV['CONVERSIONS_FUNDRAISE_CAMPAIGN_ID']
          }.to_json
        end
      end

      get '/:graph_id/*' do
        content_type :json
        proxy_get_to_fb(request, response)
      end

      post '/*' do
        content_type :json
        return proxy_post_to_fb(request, response)
      end

      get '/*' do
        proxy_get_to_fb(request, response)
      end
    end
  end
end
