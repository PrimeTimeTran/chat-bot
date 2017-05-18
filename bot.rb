require 'http'

class Bot
  def fb_url
    "https://graph.facebook.com/me/messages?access_token=" + ENV['PAGE_ACCESS_TOKEN']
  end

  def send_message(recipient_id, message_text)
    data = {recipient: {id: recipient_id}, message: {text: message_text}}
    HTTP.post(fb_url, json: data)
  end
end
