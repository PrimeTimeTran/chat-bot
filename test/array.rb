# def find_index(name)
#   a = ["Loi", "Harley", "Kathy"]
#   count = 0
#
#   until count == a.count
#     if a[count] == name
#       return count
#     end
#     count += 1
#   end
# end

# def find_index(name)
#   count = 0
#   a = ["Loi", "Harley", "Kathy"]
#
#   a.each do |val|
#     if val == name
#       return count
#     else
#       count += 1
#     end
#   end
#
#   return nil
# end

 # def find_index(name)
 #   a = ["Loi", "Harley", "Kathy"]
 #
 #   a.each_with_index do |val, index|
 #     if val == name
 #       return index
 #     end
 #   end
 #
 #   return nil
 # end
#
# def find_index(name)
#   a = ["Loi", "Harley", "Kathy"]
#   a.index{|x| x == name}
# end

def find_index(name)
 a = ["Loi", "Harley", "Kathy"]
 a.index(name)
end

p find_index("Loi")
p find_index("Harley")
p find_index("Charles")
p find_index("Kathy")
