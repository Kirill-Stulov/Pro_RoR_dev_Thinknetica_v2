=begin
  Площадь треугольника. Площадь треугольника можно вычислить, зная его основание (a) и высоту (h) по формуле: 1/2*a*h. 
  Программа должна запрашивать основание и высоту треугольника и возвращать его площадь.
=end

puts "Let's calculate triangle area!"
sleep 2
puts "Please enter traingle base length in cm"
base = gets.chomp.to_f
puts "Please enter triangle height in cm"
height = gets.chomp.to_f
puts "calculating triangle area..."
result = (base / 2) * height 
sleep 2
puts "Triangle area is: #{result} cm"
