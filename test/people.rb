@hash = {"Loi" => "man", "Harley" => "man", "Kathy" => "woman", "Charles" => "man", "Chloe" => "woman"}

def find_people(gender)
  people = []
  @hash.each do |key, value|
    if value == gender
      people << key
    end
  end
  return people
end

a = find_people("woman")
b = find_people("man")
