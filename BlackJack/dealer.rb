
class Dealer
  include Deck

  # шаблон регулярки, котор соответствует картам с цифрами от 2 до 10 включительно. 
  # Проверяется, что первый символ карты - число в диапозоне от 0 до 9 или 10 
  NUM_CARD = /^[2-9]|10/
  # шаблон регулярки, котор соответствует всем тузам 
  # Проверяется, что первый символ карты - A
  A_CARD = /^A/
  # шаблон регулярки, котор соответствует картам с картинками 
  # Проверяется, что первый символ карты - J или Q или K 
  PIC_CARD = /^J|Q|K/

  attr_accessor :name, :cards, :score, :cash

  def initialize
    @name = 'Dealer'
    @cards = []
    @score = 0
    @cash = 100
  end

# !!! где-то что-то можно реализовать через метод принимающий блок
# прим. def train_detail(&block)

  # method gives random card to player or dealer
  #  by adding it to p1 cards array and deleting it from DECK array
  def self.give_rcard(player)
    # fetching random card from DECK strings array
    rand_card = DECK.sample
    # adding given card to player
    player.cards << rand_card
    # deleting card from deck
    DECK.delete(rand_card)
    card_calc(player, rand_card)
  end

  # метод чтобы получать число из случайно выбранной карты !!! этот метод нужно перенести в system.rb
  #  «картинки» (J, Q, K) - по 10, 
  #  туз (А)- 1 или 11, в зависимости от того, какое значение будет ближе к 21 и что не ведет к проигрышу (сумме более 21)
  def self.card_calc(player, card)
    # обрезаем хвост у карты, чтобы получилось голое число и присваиваем переменной stripped_num
    # тут '\1' - это строка на которую после обрезания заменяется значение и остается только первый символ.
    stripped_num = card.sub(/([2-9]|10).*/, '\1')
    case card
    when NUM_CARD
      #1. валидация 
      player.score += stripped_num.to_i
    when A_CARD
      # игрок имеет возможность выбрать 1 или 10, тут нужно сделать helper
      one_or_ten(player, card)
    when PIC_CARD
      player.score += 10
    end
  end

  # card_calc helper method 1  
  def self.one_or_ten(player, card)
    puts "#{player.name} got #{card}. Enter 1 - for 1 or 2 for 10"
    input = gets.chomp
    case input
    when '1' 
      player.score += 1
    when '2'
      player.score += 10 
    else
      puts 'Wrong enter!'
    end
  end
end
