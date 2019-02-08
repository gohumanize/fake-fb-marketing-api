module FakeFbMarketingApi
  class FakeFacebook

    attr_accessor :instance
    attr_accessor :owned_ad_accounts

    def self.setup
      @instance = FakeFbMarketingApi::FakeFacebook.new
    end

    def initialize
      @owned_ad_accounts = []
    end

    def self.owned_ad_accounts
      @instance.owned_ad_accounts
    end

    def self.add_owned_ad_account(ad_account_hash)
      @instance.owned_ad_accounts << ad_account_hash
    end
  end
end
