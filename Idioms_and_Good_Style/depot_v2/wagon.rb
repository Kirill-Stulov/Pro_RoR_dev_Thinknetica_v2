# frozen_string_literal: true

# wagon class, has two child classes - cargo_wagon & passenger_wagon
class Wagon
  include Manufacturer
  attr_reader :type, :number, :manufacturer

  def initialize(number)
    @number = number # Номера вагонов создаются автоматически, валидация не нужна
    @type = type      # Тип вагонов в валидации не нуждается, т.к создается в зависимости от типа выбранного поезда
    @manufacturer = nil
  end
end
