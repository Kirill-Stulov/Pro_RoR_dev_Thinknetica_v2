# frozen_string_literal: true

# passenger train class - creates instances of exactly passenger trains
# differs by type of train - :passenger
class PassengerTrain < Train
  def initialize(number, options = {})
    super
    options[:type] = :passenger
    options[:manufacturer] = 'TASH'
    # @type = :passenger
    # trains_collect
  end
end
