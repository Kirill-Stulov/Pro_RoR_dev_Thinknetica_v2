# perfect weight
puts 'Lets check your weight!'
sleep 2
puts "Whats your name?"
name = gets.chomp.to_s
puts "what is your height?"
height = gets.chomp.to_i
puts "calculating parameters..."
result = (height - 110) * 1.15
sleep 3
if result > 0
  puts "#{name}, your perfect weight must be #{result}kg!"
else 
  puts "Good news #{name}, your weight is already perfect!"
  sleep 2
  puts "Sad news here..."
  sleep 2
  puts "you're probably a halfling..."
  sleep 2
  puts "a dwarf?!"
  sleep 2 
  puts "Behold you filthy abomination!!! >_<"
end
