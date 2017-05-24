require 'sinatra'
require 'http'
require 'json'
require 'awesome_print'
require_relative 'bot'
require 'easy_translate'

get '/callback' do
  if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == "asdf123"
    params["hub.challenge"]
  else
    ap "Give me Parameters"
    "Unknown Parmeters"
  end
end

EasyTranslate.api_key= ENV['TRANSLATE_API_KEY']
@@users = {}

def language(id)
  languages = EasyTranslate::LANGUAGES.invert
  choice = @@users[id].downcase
  languages.each do |key, value|
    if key == choice
      return {to: value.to_sym}
    end
  end
  return nil
end

post '/callback' do
  data = JSON.parse(request.body.read)
  ap data
  entries = data["entry"]
  entries.each do |entry|
    entry["messaging"].each do |messaging|
      sender_id = messaging["sender"]["id"]
      text = messaging["message"]["text"]

      unless @@users[sender_id]
        Bot.new.send_message(sender_id, "To what language would you like me to translate? I know a lot")
        Bot.new.send_message(sender_id, "Please respond with '/language'. For example, '/English'")
      end

      @@users[sender_id] ||= "English"

      if text[0] == "/"
        @@users[sender_id] = text[1..-1]
      end

      choice = language(sender_id)

      if choice == nil
        Bot.new.send_message(sender_id, "Sorry couldn't find #{@@users[sender_id]} so I'm going to speak English for now.")
        Bot.new.send_message(sender_id, "Please try another language with '/language'. For example, '/English' for translations to English")
      else
        reply = EasyTranslate.translate(text, choice)
        Bot.new.send_message(sender_id, reply)
      end
    end
  end
  'ok'
end
