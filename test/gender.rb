@hash = {"Loi" => "man", "Harley" => "man", "Kathy" => "woman"}

def find_gender(name)
  @hash.each {|key, value| return value if name == key  }
end

p find_gender("Loi")
p find_gender("Harley")
p find_gender("Kathy")
