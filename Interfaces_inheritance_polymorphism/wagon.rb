# Вагоны теперь делятся на грузовые и пассажирские (отдельные классы). К пассажирскому поезду можно прицепить только пассажирские, к грузовому - грузовые. 
# При добавлении вагона к поезду, объект вагона должен передаваться как аргумент метода и сохраняться во внутреннем массиве поезда, в отличие от предыдущего задания, где мы считали только кол-во вагонов. Параметр конструктора "кол-во вагонов" при этом можно удалить.
class PassengerWagon
  attr_reader :type, :number

  def initialize(number)
    @number = number
    @type = :passenger
  end

end

class CargoWagon
  attr_reader :type, :number

  def initialize(number)
    @number = number
    @type = :cargo
  end

end
