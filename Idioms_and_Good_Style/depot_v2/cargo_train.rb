# frozen_string_literal: true

# cargo train class - creates instances of exactly cargo trains
# differs by type of train - :cargo
class CargoTrain < Train
  def initialize(number, options = {})
    super
    options[:type] = :cargo
    # @type = :cargo
  end
end
