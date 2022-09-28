# Номера вагонов создаются автоматически, валидация не нужна 
# Тип вагонов тоже в валидации не нуждается, т.к в интерфейсе создается в зависимости от типа выбранного поезда
class Wagon
  include Manufacturer
  attr_reader :type, :number, :manufacturer

  def initialize(number)
    @number = number
    @type = type
    @manufacturer = nil
  end
end
