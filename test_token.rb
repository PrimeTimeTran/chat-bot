require 'http'
require 'json'
require 'awesome_print'

def fb_url
  "https://graph.facebook.com/v2.6/me/messages?access_token=" + ENV['PAGE_ACCESS_TOKEN']
end

def test_fb_token
  response = HTTP.post(fb_url)
  ap JSON.parse(response.to_s)
end

test_fb_token
