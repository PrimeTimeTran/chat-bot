require 'sinatra'
require 'http'
require 'json'
require 'awesome_print'
require_relative 'bot'
require 'easy_translate'

EasyTranslate.api_key= ENV['TRANSLATE_API_KEY']

@@lang = "English"
@@count = 1
@@count_for_first = 0


def language(lang)
  if lang == "English"
    {to: :en}
  elsif lang == "Vietnamese"
    {to: :vi}
  elsif lang == "French"
    {to: :fr}
  end
end

get '/callback' do
  if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == "asdf123"
    params["hub.challenge"]
  else
    ap "Give me Parameters"
    ap params
    "Unknown Parmeters"
  end
end

post '/callback' do
  data = JSON.parse(request.body.read)
  ap data
  entries = data["entry"]
  entries.each do |entry|
    entry["messaging"].each do |messaging|
      sender_id = messaging["sender"]["id"]
      text = messaging["message"]["text"]

      if @@count <= 1
        Bot.new.send_message(sender_id, "What language would you like me to translate?")
        @@count += 1
      end

      if text == "language:Vietnamese" || (text == "Vietnamese" && @@count <= 2)
        Bot.new.send_message(sender_id, "Ok, I'll translate to Vietnamese. If you'd like to change it in the future tell me 'language:Your_Language'")
        @@lang = "Vietnamese"
        ap @@lang
        @@count += 1
      elsif text == "language:English" || (text == "English" && @@count <= 2)
        Bot.new.send_message(sender_id, "Ok, I'll translate to English.. If you'd like to change it in the future tell me 'language:Your_Language'")
        @@lang = "English"
        ap @@lang
        @@count += 1
      elsif text == "language:French" || (text == "French" && @@count <= 2)
        Bot.new.send_message(sender_id, "Ok, I'll translate to French.. If you'd like to change it in the future tell me 'language:Your_Language'")
        @@lang = "French"
        ap @@lang
        @@count += 1
      else
      end

      if @@count_for_first == 0
        @@count_for_first += 1
      else
        reply = "You said: #{text}"
      end

      reply = EasyTranslate.translate(text, language(@@lang))
      Bot.new.send_message(sender_id, reply)
    end
  end
  'ok'
end
