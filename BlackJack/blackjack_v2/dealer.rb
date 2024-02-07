# frozen_string_literal: true

require_relative 'interface'
require_relative 'player'

# dealer class
class Dealer < Player
  # include SharedVars # no need, SharedVars already included in Player class
  # extend SharedVars::ClassMethods
  include Deck

  # шаблон регулярки, котор соответствует картам с цифрами от 2 до 10 включительно.
  # Проверяется, что первый символ карты - число в диапозоне от 0 до 9 или 10
  NUM_CARD = /^[2-9]|10/.freeze
  # шаблон регулярки, котор соответствует всем тузам
  # Проверяется, что первый символ карты - A
  A_CARD = /^A/.freeze
  # шаблон регулярки, котор соответствует картам с картинками
  # Проверяется, что первый символ карты - J или Q или K
  PIC_CARD = /^J|Q|K/.freeze

  # attr_accessor :name, :cards, :score, :cash # no need - same attributes inherits from player class

  def initialize(name = 'Dealer')
    # через super параметры @cards = []; @score = 0; @cash = 100; Player.players_collect(self) наследуются от player
    super
  end

  # !!! где-то что-то можно реализовать через метод принимающий блок
  # прим. def train_detail(&block)

  # parent method gives random card to player or dealer
  #  by adding it to p1 cards array and deleting it from DECK array
  def self.give_rcard(player, deck)
    # first checking if player allowed to hit by validate_hit and break into previous menu if true
    # if !Validation.validate_hit(player)#.false?
    # 'return if' acts as guard clause, if validate_hit returns true,
    #  method returns early and rest code will not be executed
    return if Validation.validate_hit(player)

    # fetching random card from DECK strings array
    # rand_card = DECK.sample
    rand_card = deck.sample
    # adding given card to player
    player.cards << rand_card
    # deleting card from deck
    # DECK.delete(rand_card)
    deck.delete(rand_card)
    card_calc(player, rand_card)
  end

  # using case instead of hash is way more complicated!
  #  decided to stick to case instead of hash
  # def self.types(player, card)
  #   stripped_num = card.sub(/([2-9]|10).*/, '\1')
  #   { NUM_CARD => Proc.new { player.score += stripped_num.to_i }, # stripped_num!
  #     A_CARD => Proc.new { one_or_ten(player, card) },
  #     PIC_CARD => Proc.new { player.score += 10 }
  #   }
  # end

  # give_rcard child method
  # метод чтобы получать число из случайно выбранной карты !!! этот метод нужно перенести в system.rb
  #  «картинки» (J, Q, K) - по 10,
  #  туз (А)-1 или 11, в зависимости от того какое значение будет ближе к 21
  #  и что не ведет к проигрышу (сумме более 21)
  # нужно оптимизирвоать через send
  def self.card_calc(player, card)
    # обрезаем хвост у карты, чтобы получилось голое число и присваиваем переменной stripped_num
    # тут '\1' - это строка на которую после обрезания заменяется значение и остается только первый символ.
    stripped_num = card.sub(/([2-9]|10).*/, '\1')

    case card
    when NUM_CARD
      # 1. валидация
      player.score += stripped_num.to_i
    when A_CARD
      # helper метод one_or_ten - игрок имеет возможность выбрать 1 или 10
      one_or_ten(player, card)
    when PIC_CARD
      player.score += 10
    end
  end

  # # пример send
  # def self.one_or_ten(player, card)
  #   method_name = player.name == 'Dealer' ? :one_or_ten_dealer : :one_or_ten_player
  #   player.send(method_name, card)
  # end

  # card_calc helper - child method 1
  # это можно переделать через send
  def self.one_or_ten(player, card)
    if player.name == 'Dealer'
      one_or_ten_dealer(player)
    else
      # если это игрок - дается возможность выбора в консоли
      one_or_ten_player(player, card)
    end
  end

  def self.one_or_ten_player(player, card)
    # этот цикл необходим чтобы заново предлагать ввод, если ввод был неверен и выводим 'Wrong enter!'
    loop do
      puts "#{player.name} got #{card}. Enter 1 - for 1 or 2 for 10"
      input = gets.chomp.to_i
      if (1..2).include?(input)
        player.score += (input == 1 ? 1 : 10)
        # выходим из цикла если ввод был верен (т.е в диапозоне от 1 до 2)
        break
      else
        # если ввод не в диапозоне - возвращаемся в цикл и предлагаем ввести заново Enter 1 - for 1 or 2 for 10"
        puts 'Wrong enter!'
      end
    end
  end

  # one_or_ten child method
  #  contains dealer logic to decide which score to pic, 1 or 10
  #  если это его первая карта, то всегда 10
  #  если вторая или третья, то берет так чтобы не сгореть
  def self.one_or_ten_dealer(dealer)
    puts 'Dealer selecting 1 or 10 now!'
    sleep 3
    ds = dealer.score
    dcs = dealer.cards.size
    # если это его первая карта, то 10, или если счет < или = 11 то 10, иначе 1
    dealer.score += (dcs.zero? || ds <= 11) ? 10 : 1
  end

  # method of dealer play. вызывается в интерфейсе в методе player_selections
  #  тут дилер сам в зависимости от условий, принимает решение добавить или пропустить
  #   - dealer can stand only if his his score >= 17 (ход переходит игроку)
  #   - dealer hit only if his score < 17
  def self.hit_or_stand(dealer, player, deck)
    if safe_to_hit?(player)
      # !!! если тут дилеру выпадает туз, он должен решать 1 или 10
      hit_allowed?(dealer) ? give_rcard(dealer, deck) : Interface.dealer_text
    else
      # !!! если тут дилеру выпадает туз, он решает брать 1 или 10 через метод 'one_or_ten_dealer'
      stand_allowed?(dealer) ? Interface.dealer_text : give_rcard(dealer, deck)
    end
  end

  def self.stand_allowed?(dealer)
    dealer.score >= 17
  end

  def self.safe_to_hit?(player)
    player.cards.size == 3
  end

  def self.hit_allowed?(dealer)
    dealer.score < 17 && dealer.cards.length < 3
  end
end
