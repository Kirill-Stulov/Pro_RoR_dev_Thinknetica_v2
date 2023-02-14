# frozen_string_literal: true

# cargo wagon class - creates instances of exactly cargo class
class CargoWagon < Wagon
  attr_reader :max_volume

  def initialize(number)
    super
    @type = :cargo
    # объем грузового вагона равен по умолчанию 132 тонны, это значение принимаю за 100%
    @max_volume = 132
    # @total_free_volume - оставшийся свободный объем. На момент создания...
    # ...это кол-во равно общему объему - @max_volume
    @total_free_volume = @max_volume.to_f
  end

  # метод занимает объем
  def occupy_volume(vol)
    # выбрасываем исключение, если введен объем больший чем есть свободного места в вагоне
    raise 'Entered volume exceeds max vagon volume or current free vagon volume!' if vol > @total_free_volume

    @total_free_volume -= vol
  end

  # метод вычисляет и возвращает занятый объем
  def show_occupied_volume
    @max_volume - @total_free_volume
  end

  # метод, возвращает оставшийся (доступный) объем
  def show_free_volume
    @total_free_volume
  end
end
