# FakeFbMarketingApi

This sinatra server provides a reverse proxy to the Facebook graph API at `graph.facebook.com`.

Select APIs can intercepted and return static responses.

## Setup

### Koala

These instructions assume that you are using [Koala](https://github.com/arsduo/koala) as your interface to the Facebook graph API.

In order to use this reverse proxy, you will need to redirect all Koala requests to your local `fake-fb-marketing-api` server.

In your Koala config, replace the URL for FB:
```
Koala.configure do |config|
  if Rails.env.development?
    config.graph_server = 'localhost:9292'
  end
end
``` 

In your Koala config, you will also need to disable SSL since our local server is not running with certificates:
```
Koala.http_service.http_options = {
  use_ssl: false
}
```

You will also need to set several `ENV` variables:
```
export FACEBOOK_AD_ACCOUNT_ID='xxxxxx' 
export BRAND_AWARENESS_CAMPAIGN_ID='xxxxxx' 
export LINK_CLICKS_CAMPAIGN_ID='xxxxxx' 
export VIDEO_VIEWS_CAMPAIGN_ID='xxxxxx' 
export REACH_CAMPAIGN_ID='xxxxxx' 
export POST_ENGAGEMENT_CAMPAIGN_ID='xxxxxx' 
export PAGE_LIKES_CAMPAIGN_ID='xxxxxx' 
```

It may be easier to run foreman with a separate ENV file that will set these values:
```
foreman start --f Procfile.dev --env fake.env
```
*Note* Foreman is particular about the format of the ENV file and does not support dot_env format (comments, etc.).  This prevents us from using our normal `.env.development` to set variables for the entiree process.

Any calls that create an ad account will return the value in the `FACEBOOK_AD_ACCOUNT_ID`.  

Any campaigns created will return the value in the `XXX_CAMPAIGN_ID` variables.
 
## Notes

### Limitations

This server forwards all web requests via a Faraday wrapper.  It does not support `keep-alive` `Connection` header.
