puts 'Whats your name?'
name = gets.chomp
puts 'Please enter year of birth'
b_year = gets.chomp.to_i
puts "#{name}, hi!"
puts "your age is around: #{2022 - b_year}!"
