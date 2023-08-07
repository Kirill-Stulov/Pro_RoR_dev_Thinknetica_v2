class Player

  attr_accessor :name, :cards, :score, :cash

  def initialize(name)
    @name = name
    @cards = []
    @score = 0
    @cash = 100
  end 
end
