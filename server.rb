require 'sinatra'
require 'http'
require 'json'
require 'awesome_print'
require_relative 'bot'
require 'easy_translate'

EasyTranslate.api_key= ENV['TRANSLATE_API_KEY']

@@lang = "English"
@@initial = 0
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

      # Logic for if to send the initial message to user
      # Need to work on adding this feature to EACH INDIVIDUAL USER
      if @@initial == 0
        Bot.new.send_message(sender_id, "What language would you like me to translate?")
        @@initial += 1
      end

      # Language choice
      if text == "/Vietnamese" || (text == "Vietnamese" && @@initial <= 1)
        Bot.new.send_message(sender_id, "Ok, I'll translate to Vietnamese. If you want to change later simply say '/Language'")
        @@lang = "Vietnamese"
        @@initial += 1
      elsif text == "/English" || (text == "English" && @@initial <= 1)
        Bot.new.send_message(sender_id, "Ok, I'll translate to English. If you want to change later simply say '/Language'")
        @@lang = "English"
        @@initial += 1
      elsif text == "/French" || (text == "French" && @@initial <= 1)
        Bot.new.send_message(sender_id, "Ok, I'll translate to French. If you want to change later simply say '/Language'")
        @@lang = "French"
        @@initial += 1
      else
      end

      # Transition between asking what language to "You said"
      if @@count_for_first == 0
        @@count_for_first += 1
      else
        reply = "You said: #{text}"
      end

      # Bot responds with translation language of users choice.
      reply = EasyTranslate.translate(text, language(@@lang))
      Bot.new.send_message(sender_id, reply)
    end
  end
  'ok'
end
