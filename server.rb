require 'sinatra'
require 'http'
require 'json'
require 'awesome_print'
require_relative 'bot'
require 'easy_translate'

EasyTranslate.api_key= ENV['TRANSLATE_API_KEY']

get '/' do
   ap params # print the params out
  "Hello World!"
end

get '/callback' do
  if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == "asdf123"
    params["hub.challenge"]
  else
    ap "Unknown params:"
    ap params
    'Stay away with these bad requests!'
  end
end

post '/callback' do
  data = JSON.parse(request.body.read)
  ap data
  entries = data["entry"]
  entries.each do |entry|
    entry["messaging"].each do |messaging|
      sender_id = 1486384961431995
      text = messaging["message"]["text"]
      reply = "You said: #{text}"
      Bot.new.send_message(sender_id, reply)
    end
  end
  'ok'
end


# reply = EasyTranslate.translate(text, to: :vi)
