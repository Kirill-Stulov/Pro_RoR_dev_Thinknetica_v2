# Для грузовых вагонов:
# 	Добавить атрибут общего объема (задается при создании вагона)- добавил initial_volume (равен по умолчанию 132 тоннам)
# 	Добавить метод, которые "занимает объем" в вагоне (объем указывается в качестве параметра метода) - Добавил метод occupy_volume
# 	Добавить метод, который возвращает занятый объем - Добавил метод show_occupied_volume
#   Добавить метод, который возвращает оставшийся (доступный) объем

class CargoWagon < Wagon
  attr_reader :initial_volume

  def initialize(number)
    super
    @type = :cargo
    @initial_volume = 132                                     # объем грузового вагона равен по умолчанию 132 тонны, это значение принимаю за 100%
    @total_free_volume = @initial_volume.to_f                 # оставшийся свободный объем в вагоне. На момент создания вагона это кол-во равно общему объему - @initial_seats
  end

  def occupy_volume(vol)                                      # метод занимает объем
    @total_free_volume -= vol
  end

  def show_occupied_volume                                    # метод вычисляет и возвращает занятый объем
    @occupied_volume = @initial_volume - @total_free_volume
  end

  def show_free_volume                                        # метод, который возвращает оставшийся (доступный) объем
    @total_free_volume
  end
end
