require 'sinatra'
require 'http'
require 'json'
require 'awesome_print'
require_relative 'bot'
require 'easy_translate'

EasyTranslate.api_key= ENV['TRANSLATE_API_KEY']

@@initial = 0
@@users = {}

def language(key)
  if @@users[key] == "English"
    {to: :en}
  elsif @@users[key] == "Vietnamese"
    {to: :vi}
  elsif @@users[key] == "French"
    {to: :fr}
  else
    {to: :en}
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
  entries = data["entry"]
  entries.each do |entry|
    entry["messaging"].each do |messaging|
      sender_id = messaging["sender"]["id"]
      text = messaging["message"]["text"]

      # Logic for if to send the initial message to user
      # Need to work on adding this feature to EACH INDIVIDUAL USER
        unless @@users[sender_id]
          Bot.new.send_message(sender_id, "To what language would you like me to translate?")
        end

        @@users[sender_id] ||= []

        # Language choice
        if text == "/Vietnamese" || (text == "Vietnamese" && @@initial <= 1)
          Bot.new.send_message(sender_id, "Ok, I'll translate to Vietnamese. If you want to change later simply say '/Language'")
          @@users[sender_id] = "Vietnamese"
          @@initial += 1
        elsif text == "/English" || (text == "English" && @@initial <= 1)
          Bot.new.send_message(sender_id, "Ok, I'll translate to English. If you want to change later simply say '/Language'")
          @@users[sender_id] = "English"
          @@initial += 1
        elsif text == "/French" || (text == "French" && @@initial <= 1)
          Bot.new.send_message(sender_id, "Ok, I'll translate to French. If you want to change later simply say '/Language'")
          @@users[sender_id] = "French"
          @@initial += 1
        else
        end

      reply = "You said: #{text}"

      # Bot responds with translation language of users choice.
      reply = EasyTranslate.translate(text, language(sender_id))
      Bot.new.send_message(sender_id, reply)
    end
  end
  'ok'
end
