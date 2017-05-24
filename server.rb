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
  EasyTranslate::LANGUAGES.invert[@@users[id][:language].downcase]
end

post '/callback' do
  data = JSON.parse(request.body.read)
  entries = data["entry"]
  entries.each do |entry|
    entry["messaging"].each do |messaging|
      sender_id = messaging["sender"]["id"]
      text = messaging["message"]["text"]

      @@users[sender_id] ||= {}
      @@users[sender_id][:language] ||= "English"
      @@users[sender_id][:conversation_type] ||= 'initial'
      conversation_type = @@users[sender_id][:conversation_type]
        case conversation_type
          when 'initial'
            @@users[sender_id][:conversation_type] = 'begun'
            ap @@users
            Bot.new.send_message(sender_id, "To what language would you like me to translate? I know a lot \nPlease respond with '/language'. For example, '/English'")

          when 'language'
            @@users[sender_id][:language] = text
            choice = language(sender_id)
            if choice == nil
              @@users[sender_id][:conversation_type] ='begun'
              ap @@users
              Bot.new.send_message(sender_id, "Sorry couldn't find #{@@users[sender_id][:language]} so I'm going to speak English for now.\nPlease try another language with '/language'. For example, '/English' for translations to English")
            else
              @@users[sender_id][:conversation_type] = 'begun'
              ap @@users
              Bot.new.send_message(sender_id, "Ok, I'll translate to #{@@users[sender_id][:language]}")
            end

          when 'begun'
            if text.start_with?("/") && text.downcase != "/language"
              @@users[sender_id][:language] = text[1..-1]
              text = text[1..-1]
            end

            if text.downcase == "/language"
              @@users[sender_id][:conversation_type] = 'language'
              ap @@users
              Bot.new.send_message(sender_id, "What language would you like to select?")
              text = text[1..-1]
            else
              choice = language(sender_id)
              reply = EasyTranslate.translate(text, to: choice)
              ap @@users
              Bot.new.send_message(sender_id, reply)
            end

          else
        end

    end
  end
  'ok'
end
