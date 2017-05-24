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

# Original Way I wrote the method
  # def language(id)
  #   languages = EasyTranslate::LANGUAGES.invert
  #   choice = @@users[id][:language].downcase
  #   languages.each do |key, value|
  #     if key == choice
  #       return {to: value.to_sym}
  #     end
  #   end
  #   return nil
  # end

# Cleaner way to write the language method
  def language(id)
    EasyTranslate::LANGUAGES.invert[@@users[id][:language].downcase]
  end

post '/callback' do
  data = JSON.parse(request.body.read)
  ap data
  entries = data["entry"]
  entries.each do |entry|
    entry["messaging"].each do |messaging|
      sender_id = messaging["sender"]["id"]
      text = messaging["message"]["text"]

      # unless @@users[sender_id]
      #   Bot.new.send_message(sender_id, "To what language would you like me to translate? I know a lot")
      #   Bot.new.send_message(sender_id, "Please respond with '/language'. For example, '/English'")
      # end
      #
      # @@users[sender_id] ||= {}
      # @@users[sender_id][:language] ||= "English"
      # @@users[sender_id][:conversationType] ||= 'initial'
      #
      # if text[0] == "/"
      #   @@users[sender_id][:language] = text[1..-1]
      # end
      #
      # ap @@users
      # choice = language(sender_id)
      #
      # if choice == nil
      #   Bot.new.send_message(sender_id, "Sorry couldn't find #{@@users[sender_id][:language]} so I'm going to speak English for now.")
      #   Bot.new.send_message(sender_id, "Please try another language with '/language'. For example, '/English' for translations to English")
      # else
      #   reply = EasyTranslate.translate(text, to: choice)
      #   Bot.new.send_message(sender_id, reply)
      # end
      @@users[sender_id] ||= {}
      @@users[sender_id][:language] ||= "English"
      @@users[sender_id][:conversationType] ||= 'initial'
      conversationType = @@users[sender_id][:conversationType]
        case conversationType
          when 'initial'
            @@users[sender_id][:conversationType] = 'begun'
            Bot.new.send_message(sender_id, "To what language would you like me to translate? I know a lot")
            Bot.new.send_message(sender_id, "Please respond with '/language'. For example, '/English'")
          when 'language'
            @@users[sender_id][:language] = text
            choice = language(sender_id)
            if choice == nil
              @@users[sender_id][:conversationType] ='begun'
              Bot.new.send_message(sender_id, "Sorry couldn't find #{@@users[sender_id][:language]} so I'm going to speak English for now.")
              Bot.new.send_message(sender_id, "Please try another language with '/language'. For example, '/English' for translations to English")
            end
            ap @@users
            @@users[sender_id][:conversationType] = 'begun'
            Bot.new.send_message(sender_id, "Ok, I'll translate to #{@@users[sender_id][:language]}")
          when 'begun'
            if text[0] == "/" && text != '/language'
              @@users[sender_id][:language] = text[1..-1]
              text = text[1..-1]
            end

            if text == "/language"
              @@users[sender_id][:conversationType] = 'language'
              Bot.new.send_message(sender_id, "What language would you like to select?")
              text = text[1..-1]
            else
              choice = language(sender_id)
              reply = EasyTranslate.translate(text, to: choice)
              Bot.new.send_message(sender_id, reply)
            end
          else
        end

    end
  end
  'ok'
end
