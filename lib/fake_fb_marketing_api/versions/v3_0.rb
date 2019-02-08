# frozen_string_literal: true

require_relative '../base'

module FakeFbMarketingApi
  module Versions
    class V30 < Base
      set_namespace 'v3.0'

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
