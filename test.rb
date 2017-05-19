require 'awesome_print'
@store = {}

a = "first"
@store[a] ||= []
@store["first"] = "English"

a = "second"
@store[a] ||= []
@store["second"] = "Vietnamese"

a = "third"
@store[a] ||= []
@store["third"] = "French"

def language(sender_id)
  if @store[sender_id] == "English"
    {to: :en}
  elsif @store[sender_id] == "Vietnamese"
    {to: :vi}
  elsif @store[sender_id] == "French"
    {to: :fr}
  else
    puts "Sorry but your id doesn't have a language preference yet!"
  end
end


ap language("first")
ap language("second")
ap language("third")
ap language("Hello")
