# frozen_string_literal: true

# Spades:
# A^ 2^ 3^ 4^ 5^ 6^ 7^ 8^ 9^ 10^ J^ Q^ K^

# Hearts:
# A<3 2<3 3<3 4<3 5<3 6<3 7<3 8<3 9<3 10<3 J<3 Q<3 K<3

# Diamonds:
# A<> 2<> 3<> 4<> 5<> 6<> 7<> 8<> 9<> 10<> J<> Q<> K<>

# Clubs:
# A+ 2+ 3+ 4+ 5+ 6+ 7+ 8+ 9+ 10+ J+ Q+ K+

# Module contains list of strings representing a standard deck of cards
module Deck
  ORIGINAL_DECK = %w[A^ 2^ 3^ 4^ 5^ 6^ 7^ 8^ 9^ 10^ J^ Q^ K^
                     A<3 2<3 3<3 4<3 5<3 6<3 7<3 8<3 9<3 10<3 J<3 Q<3 K<3
                     A<> 2<> 3<> 4<> 5<> 6<> 7<> 8<> 9<> 10<> J<> Q<> K<>
                     A+ 2+ 3+ 4+ 5+ 6+ 7+ 8+ 9+ 10+ J+ Q+ K+].freeze
end

# Module containing all validations
module Validation
  # сохраняем в константу шаблон имени игрока.
  #   Шаблон: не менее и не более 12 букв. [a-z] Any single character in the range a-z;
  #   {1,12} - диапозон от 1 до 12 букв. ^ - начало строки; $ - конец строки;
  #   /i модификатор убирает чувствительность к регистру
  NAME_FORMAT = /^[a-z]{1,12}$/i.freeze

  # VALIDATIONS is a hash constant that contains a collection of validation rules.
  # values of the hash are lambda functions that implement the corresponding validation rule
  #  where 'value' is always the value that needs to be validated
  #  arg is optional and used for some types of validations, such as :format or :type
  #  raises an exception if the validation fails.
  VALIDATIONS = {
    # player name enter can not be empty
    presence: ->(value, _arg) { raise 'Name cannot be empty!' if value.nil? || value.empty? },
    # player name must match to STNAME_FORMAT pattern
    format: ->(value, arg) { raise 'Wrong name format entered!' if value !~ arg },
    # player can hit only if his total cards less than 3!
    cards_limit: ->(value, _arg) { raise 'You cannot hit more!' if value.length == 3 },
    # валидация по cash игрока, выводить что недостатьчно средств, если cash < 10
    cash_limit: ->(value, arg) { raise "Player #{arg} insufficient funds!" if value <= 0 }
  }.freeze

  def self.validate(object_or_string, attr_name, validation_type, arg = nil)
    value = object_or_string.is_a?(String) ? object_or_string : object_or_string.send(attr_name)
    VALIDATIONS[validation_type].call(value, arg)
  end

  # validation method checks name entered is not empty, nil and corresponds to format
  def self.validate_name(player_name)
    validate(player_name, :name, :presence)
    validate(player_name, :name, :format, NAME_FORMAT)
  rescue RuntimeError => e
    puts e.message
    # если эта валидация срабатывает - то возвращаю true,
    #  это нужно чтобы срабатывал unless (next if) Validation.validate_name(player) в методе create_player
    true
  end

  # validation checks player cards limit
  def self.validate_hit(player)
    validate(player, :cards, :cards_limit, player.name)
  rescue RuntimeError => e
    puts e.message
    # если эта валидация срабатывает - то возвращаю true, это нужно чтобы
    # срабатывал unless Validation.validate_hit(player) в методе give_rcard
    true
  end

  def self.validate_cash(player)
    validate(player, :cash, :cash_limit, player.name)
  rescue RuntimeError => e
    puts e.message
    true
  end
end

# модуль хранит и предоставляет доступ к переменным, которые общие для всех классов:
# Благодяря этому не нужно писать лишних обращений и локальных переменных (instance_variable.get set etc.)
# и городить в классах переменные класса, которые к тому же делают данные публичными
# @@players = []
# @@bank
# Класс в который подключается этот модуль
#  фактически расширяется методами этого модуля
#  у меня тут в него вложены модуль с методами класса и модуль с инстанс методом
module SharedVars
  # это нужно чтобы в классе, в котором подключаем этот модуль
  #  было достаточно написать include InstanceCounter, вместо "extend InstanceCounter::ClassMethods"
  #  и "include InstanceCounter::InstanceMethods" (занятие 5 00:38 и занятие 9 6:00)
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  # module used to define class methods that can be included in other classes.
  module ClassMethods
    # attr_accessor :game_counter defines game_counter as a class variable, and creates a class method to access it.
    # !!! Проще и правильнее создать класс game, там инициализовать эти переменные в конструкторе,
    # а потом вызывать в нужных классах! (но для тренировки оставлю так)
    # использовать переменные класса не рекомендуется по многим причинам
    attr_accessor :game_counter # , :all_players, :bank # this is only for instance vars, not class vars

    @@all_players = []
    @@bank = 0

    def players_collect(player)
      @@all_players << player
    end

    def take_players
      @@all_players.dup
    end

    def take_bank
      @@bank.dup
    end

    # method emptyes bank, after bank money given to winner (used in winner_no_winner)
    def empty_bank
      @@bank -= 20
    end

    # method returns players bets from bank to players, if no winner
    #  used in winner_no_winner method
    def return_cash_to_players
      @@all_players.each(&:backout_cash)
      # вот так было бы проще и меньше кода, но решил оставить &:backout_cash вариант для наглядности
      # @@all_players.each { |player| player.cash += 10 }
    end

    # метод для автоматических ставок в начале игры
    # TODO! оптимизировать метод в bets и перенести его в dealer класс
    def bets
      @@all_players.each { |player| player.cash -= 10 }
      @@bank += 20
    end

    # same bets method, but for debug
    # def bets
    #   @@all_players.each do |player|
    #     puts "Before bet: #{player.name} cash is #{player.cash}"
    #     player.cash -= 10
    #     puts "After bet: #{player.name} cash is #{player.cash}"
    #   end
    #   @@bank += 20
    # end

    # метод возвращает игрока с максимальным параметром score
    def max_score_player
      # @@all_players.max_by { |player| player.score }
      @@all_players.max_by(&:score)
    end

    # метод возвращает сообщение если денег недостаточно и выходит из игры
    def not_enough_cash?
      @@all_players.any? { |player| Validation.validate_cash(player) }
    end

    # метод обнуляет карты всех игроков
    def reset_cards
      # @@all_players.each { |player| player.reset_cards_score }
      @@all_players.each(&:reset_cards_score)
    end
  end

  # module used to define instance methods that can be included in other classes.
  module InstanceMethods
    # ||= тут не сработает, потому что
    # ||= doesn't work for initializing class variables from class methods.
    # We need to directly set the class variable.
    def increase_game_counter
      # self.class.game_counter ||= []
      # self.class.game_counter += 1
      # проверка на nil делается потому что при инициализации переменной класса game_counter (выше) через attr_accessor
      #  по умолчанию присваивется nil. Т.е nil - начальное значение и потому в случае nil
      #  я привожу значение game_counter к 0,
      #  если же там уже что-то есть, то увеличиваю счетчик
      counter = self.class.game_counter
      # self.class.game_counter.nil? ? self.class.game_counter = 1 : self.class.game_counter += 1
      counter.nil? ? self.class.game_counter = 1 : self.class.game_counter += 1
    end

    # method returns players bets from bank to players, if no winner
    #  used in winner_no_winner method
    # Why this methos is here:
    # return_cash_to_players method calls backout_cash on each element
    # of @@all_players using the &:backout_cash symbol-to-proc shorthand,
    # which only works if backout_cash is an instance method
    def backout_cash
      self.cash += 10
    end
  end
end
