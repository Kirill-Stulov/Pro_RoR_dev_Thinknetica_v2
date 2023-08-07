# frozen_string_literal: true 
require_relative 'modules'
require_relative 'player'
require_relative 'dealer'
require_relative 'system'

class Interface
  
  def initialize
    # @p1 = Player.new#(player_name)
    @bank = 0
  end

  # меню
  def call
    # loop do
      intro
    loop do
      menu_text
      
      input = gets.chomp
      player_selections(input)
      break if input == '0'
    end
  end

  # 'call' helper1
  def intro
    puts 'Please enter your name to play a game'
    player_name = gets.chomp
    create_player(player_name)
    
    puts "#{@p1.name} and Dealer starting the game!"
    # calls give_rcard on Dealer, passes the @p1 player instance as the argument
    # в первый раз выдавать нужно две карты, потому вызываю метод дважды в одной строке
    Dealer.give_rcard(@p1); Dealer.give_rcard(@p1)
    bet(@p1)
    # также выдаются две первоначальные карты дилеру
    Dealer.give_rcard(@d1); Dealer.give_rcard(@d1)
    bet(@d1)
    #!!!! 
    # После раздачи, автоматически делается ставка в банк игры в размере 10 долларов от игрока и диллера. 
    #  (У игрока и дилера вычитается 10 из банка)
    show_info
  end

  # "hit" (take another card)
  # "stand" (keep their current cards)
  def menu_text
    puts "Choose next action: \n0 -> quit\n1 -> hit\n"\
    "2 -> stand"
  end

  # 'call' helper2
  def player_selections(input)
      case input 
      when '1'
        give_card(@p1) # !!!! если больше 21 - проигрыш
        puts 'player decided to hit...'
        show_info
      when '2'
        Dealer.give_rcard(@d1)
        puts 'player decided to stand...'
        show_info
      when '0'
        ' '
      else
        puts 'Wrong enter!'
      end
  end


  def create_player(name)
    @p1 = Player.new(name)
    @d1 = Dealer.new
  end

  # !!! это должен быть универсальный метод
  # в зависимости от передаваемого методу параметра - игрок или диллер
  # выдается карта, игроку или дилеру
  def give_card(who)
    case who
    when @p1
      Dealer.give_rcard(@p1)
    when @dealer
      Dealer.give_rcard(@d1)
    end
  end

  def bet(who)
    case who
    when @p1
      @p1.cash -= 10
      @bank += 10
    when @d1
      @d1.cash -= 10
      @bank += 10
    end
  end

  # method checks player and dealer score
  #  decide who wins or loose
  #  game will continue if ... 
  def win_loose(player)
  end

  #!!! карты диллера не видно до конца игры!
  def show_info
    puts "#{@p1.name} got: \n - cards: #{@p1.cards}\n"\
    " - total score: #{@p1.score}\n - cash: #{@p1.cash}"
    puts "#{@d1.name} got: \n - cards: #{@d1.cards}\n"\
    " - total score: #{@d1.score}\n - cash: #{@d1.cash}"
    puts "Game bank: #{@bank}"
  end

  # метод показывающий: 
  # 1. карты игрока (done)
      # 1.1 для этого нужен метод, выдающий карту игроку (done)
      # 1.2 в интерфейсе нужен метод вызывающий метод 1.1 (done)
  # 2. сумму очков игрока (done)
  # 2. карты диллера в виде звездочек
  # 3.

end
