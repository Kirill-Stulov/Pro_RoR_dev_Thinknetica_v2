# frozen_string_literal: true

require_relative 'modules'
require_relative 'player'
require_relative 'dealer'

# module contains methods for player actions (hit, stand, reveal, player_selections, create_player, player_selections)
module PlayerActions
  # "actions" method returns hash containing 3 key-value pairs.
  #   Each key is a string representing a player action, each value is a method
  def actions
    { '1' => method(:hit),
      '2' => method(:stand),
      '3' => method(:reveal) }
  end

  def hit
    puts 'player decided to hit...'
    give_card(@p1, @deck)
    win_loose_check(1, @p1)
  end

  def stand
    puts 'player decided to stand...'
    puts 'Dealer turn now!'
    sleep 3
    Dealer.hit_or_stand(@d1, @p1, @deck)
    win_loose_check(2, @d1)
  end

  # в reveal методе вызываю win_loose_check.
  #  это логически вернее, т.к reveal происходит либо автоматически по достижении трех карт всеми игроками
  #  либо когда игрок выбирает вскрыться - reveal, тогда и происходит проверка у кого сколько очков и кто выиграл
  #  Метод автоматически определяет условие по которому он был вызван (выбор игрока вскрыться или лимит в три карты)
  #  и выдает puts 1 или puts 2 в зависимости от ситуации
  def reveal(condition = nil)
    # если метод revel вызван с параметром limit - то вывожу 'Both players cards limit! Revealing!'
    if condition == 'limit'
      puts 'Both players cards limit! Revealing!'
    else
      # если это просто выбор игрока - то вывожу 'player_name decided to reveal cards!'
      puts "#{@p1.name} decided to reveal cards!"
    end
    win_loose_check(3)
  end

  # Variant #1 of how handle different choices
  # 'call' helper2
  def player_selections(input)
    if actions.key?(input)
      actions[input].call
    else
      puts 'Wrong input!'
    end
  end
end

# module contains methods for game actions (new_game, starting_game, play_again, go_again, create_player,
#  give_card, show_info)
module GameActions
  # 'call' helper1
  # method for first new game from the scratch
  def new_game
    create_player
    starting_game
  end

  # method to start game - distrubute first 2 cards and place bets
  def starting_game
    # обновить колоду
    #  @deck is a temp copy (by method 'dup') of ORIGINAL_DECK, which is required for current game session
    #  Deck:: means we apply to Deck module first, because starting_game is in separate module now
    @deck = Deck::ORIGINAL_DECK.dup
    # добавить к счетчику игр
    increase_game_counter
    puts "#{@p1.name} and Dealer starting the game! Tier # #{self.class.game_counter}"
    # calls give_rcard on Dealer, passes the @p1 player instance as the argument
    # в первый раз выдавать нужно две карты, поэтому вызываю метод give_rcard дважды
    #  для игрока и дилера
    # 2.times { Dealer.give_rcard(@p1, @deck); Dealer.give_rcard(@d1, @deck) }
    2.times { [@p1, @d1].each { |player| Dealer.give_rcard(player, @deck) } }
    # ставка в банк игры в размере 10 долларов от каждого игрока
    # self.class.bets - тоже что и Interface.bets т.к класс Interface расширен методами модуля SharedVars
    self.class.bets
    show_info
  end

  # Variant #3 of how handle different choices
  # method allows user to play one more time if current game is over
  def play_again
    puts "Do you want to play again? \n0 -> No\n1 -> Yes\n"
    select = gets.chomp.to_i
    if (0..1).include?(select)
      # плохая идея со вложенным тернарником, заменил на ||
      #  игрок не может сыграть еще, если больше не может поставить $10
      #  валидация по cash игрока, выводит - недостаточно средств, если cash < 10 (т.е меньше одной ставки)
      #  Interface.not_enough_cash? ? exit : go_again
      # select.zero? ? exit : (Interface.not_enough_cash? ? exit : go_again)
      select.zero? || Interface.not_enough_cash? ? exit : go_again
    else
      puts 'Wrong input!'
      play_again
    end
  end

  # play_again helper
  def go_again
    # обнуляем карты и счет игроков
    Interface.reset_cards
    # запускаем игру
    starting_game
  end

  # метод создания игрока
  def create_player
    loop do
      puts 'Please enter your name to play a game'
      player_name = gets.chomp
      next if Validation.validate_name(player_name) # !!! эта валидация должна быть в конструкторе класса player

      @p1 = Player.new(player_name)
      @d1 = Dealer.new
      # выходим из цикла если validate_name возвращает не true, т.е формат имени ок
      break unless Validation.validate_name(player_name)
      # end
    end
  end

  # в зависимости от передаваемого методу параметра - игрок или диллер
  #  выдается карта, игроку или дилеру
  def give_card(who, deck)
    player = who == @p1 ? @p1 : @d1
    Dealer.give_rcard(player, deck)
  end

  # метод вывода текущей нифы по игре
  #   карты и очки диллера не видно до конца игры!
  def show_info(show_dealer_cards = false)
    puts "#{@p1.name} got: \n - cards: #{@p1.cards}\n"\
    " - score: #{@p1.score}\n - cash: #{@p1.cash}"
    # если show_dealer_cards = false то выводим *** вместо карт дилера
    puts "#{@d1.name} got: \n - cards: #{show_dealer_cards ? @d1.cards : '***'}\n"\
    " - score: #{show_dealer_cards ? @d1.score : '***'}\n - cash: #{@d1.cash}"
    puts "Game bank: #{self.class.take_bank}"
  end
end

# module contains methods for player status check (win_loose_check, busted_or_bj,
#  busted_case, bj_case, winner_no_winner)
module PlayerStatus
  # Variant #2 of how handle different choices
  # method checks if player is in_game, busted or winner, according to argument sent with method - 1, 2 or 3
  # по умолчанию аргументу player присваивается значение nil,
  #   это нужно потому что в методе reveal я вызываю win_loose_check без аргумента player
  def win_loose_check(selection, player = nil)
    if (1..3).include?(selection)
      # первоначально проверяю на 3, потому что если 1 или 2,
      #  то вызывается один и тот-же метод busted_or_bj, хоть и на разных игроках
      selection == 3 ? winner_no_winner : busted_or_bj(player)
    else
      puts 'Wrong input!'
    end
  end

  # win_loose_check helper #1
  # method used when we know player is not in game and need to know is he busted or bj
  def busted_or_bj(player)
    # если в игре, то просто выводим инфу
    if player.in_game?
      show_info
    # если игрок не в игре, то тут два варианта - либо он busted, либо он BJ
    else
      # через send динамически вызывается либо один, либо другой метод с аргументом player
      send(player.busted? ? :busted_case : :bj_case, player)
    end
  end

  # helper #1 for busted_or_bj
  def busted_case(player)
    not_busted_player = Interface.take_players.find { |participant| !participant.busted? }
    puts "Player #{player.name} is BUSTED! with score: #{player.score}, by card #{player.cards.last}"
    puts "#{not_busted_player.name} is winner, with score: #{not_busted_player.score}"
    # giving bank to winner
    not_busted_player.cash += Interface.take_bank
    # 1.clearing bank 2.show info 3.play again
    @empty_show_play.call
  end

  # helper #2 for busted_or_bj
  def bj_case(player)
    puts "#{player.name} got BlackJack! with score: #{player.score}"
    # giving bank to winner
    player.cash += Interface.take_bank
    # 1.clearing bank 2.show info 3.play again
    @empty_show_play.call
  end

  # win_loose_check helper #2
  # method compares score of both players. Max scored becomes winner. If score same for both -no winner
  # - ставка игрока остается в банке в случае проигрыша (и переходит к выигравшему)
  # - вся сумма из банка переходит игроку в случае выигрыша
  # - ставки возвращаеются игрокам в случае ничьи
  def winner_no_winner
    # если кол-во очков одинаковое - выводим что ничья - bets goes back to bank
    if @p1.score == @d1.score
      puts 'Both players got same score! No winner!'
      # return bets from bank to both players
      Interface.return_cash_to_players
    # если кол-во очков не одинаковое у @p1 и @d1
    else
      @winner_or_not.call
    end
    # 1.clearing bank for winner 2.show info 3.play again
    @empty_show_play.call
  end
end

# ALL TODO:
# 1. карты игрока (done)
# 1.1 для этого нужен метод, выдающий карту игроку (done)
# 1.2 в интерфейсе нужен метод вызывающий метод 1.1 (done)
# 2. сумму очков игрока (done)
# 2. карты диллера в виде звездочек (done)
# 3. закончить метод win_loose_check (done)
# 3.1. использовать метод in_game в player.rb (done)
# 3.2 Когда в player_selections игрок игрок выбирает hit -
# вставляем метод win_loose_check в котором проверяем: (done)
# если busted (done)
# если blackjack (done)
# 4. использовать send вместо case (todo)
# 5. использовать hash вместо множественного ветвления в case? (todo)
# 5.1 использовать alias для длинных названий методов или переменных
# 6. нужно ли использвать метапрограммирование и диниамически создавать аксессоры?
# 7. сделать валидации:
# 7.1 игрок не может взять больше трех карт (done) by validate_hit method
# 7.2 имя игрока (done) работает только если ввести enter, если поставить пробел, то не выбрасывается исключение
# 7.3 dealer can stand only it his score >= 17 (ход переходит игроку) (done)
# 7.4 dealer hit only if his score < 17 (done)
# game_over # если true - вызвать метод предлагающий начать новую игру (done)
# 8. сумма из банка игры переходит выигравшему (done)
# 9. Если сумма очков у игрока и дилера одинаковая, то объявляется ничья
# и деньги из банка возвращаются игрокам (done)
# 8. Разбить на private - protected (pending)

# Interface allows to run game through menu, calls early methods
class Interface
  include SharedVars
  include Deck
  include PlayerActions
  include GameActions
  include PlayerStatus

  def initialize
    # proc calls 3 methods in a row
    #  т.к этот прок вызывается только в конце игры, то можно показать карты дилера show_dealer_cards = true
    @empty_show_play = proc do
      Interface.empty_bank
      show_info(show_dealer_cards = true)
      play_again
    end
    # этот proc используется для сокращения метода winner_no_winner, иной пользы от него нет
    @winner_or_not = proc do
      winner = Interface.max_score_player
      puts "#{winner.name} is WINNER! with score: #{winner.score}"
      # giving bank to winner
      winner.cash += Interface.take_bank
    end
  end

  # меню
  def call
    new_game
    loop do
      reveal('limit') if cards_limit # вскрываются если у обоих по 3 карты
      menu_text
      input = gets.chomp
      player_selections(input)
      break if input == '0'
    end
  end

  # "hit" (take another card)
  # "stand" (keep their current cards)
  # 'reveal' (reveals dealers cards, after that game counts who is closer to 21 - winner)
  def menu_text
    puts "Choose next action: \n0 -> quit\n1 -> hit\n"\
    "2 -> stand\n3 -> reveal"
  end

  # если у обоих игроков по три карты, то все вскрываются
  def cards_limit
    @p1.cards.length == 3 && @d1.cards.length == 3
  end

  # пример send
  # def self.one_or_ten(player, card)
  #   method_name = player.name == 'Dealer' ? :one_or_ten_dealer : :one_or_ten_player
  #   player.send(method_name, card)
  # end

  def self.dealer_text
    puts 'Dealer decided to stand'
  end
end
