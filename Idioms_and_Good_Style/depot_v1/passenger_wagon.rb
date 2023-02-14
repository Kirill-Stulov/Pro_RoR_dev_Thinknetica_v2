# frozen_string_literal: true

# passenger wagon class - creates instances of exactly passenger wagon
class PassengerWagon < Wagon
  attr_reader :max_seats

  def initialize(number)
    super
    @type = :passenger
    # @max_seats - общее кол-во мест в вагоне
    @max_seats = 62
    # @total_free_seats - оставшиеся свободные места в вагоне...
    # ...на момент создания вагона это кол-во равно общему кол-ву мест - @max_seats
    @total_free_seats = @max_seats
  end

  # занимает места в вагоне (по одному за раз)
  def occupy_seat
    # выбрасываем исключение, если свободных мест в этом вагоне уже нет
    raise 'All seats are off!' if @total_free_seats.zero?

    @total_free_seats -= 1
  end

  # считает и возвращает количество занятых мест в вагоне
  def show_occupied_seats
    # кол-во занятых мест равно изначальное количество минус кол-во свободных мест
    @max_seats - @total_free_seats
  end

  # возвращает кол-во свободных мест в вагоне
  def show_free_seats
    @total_free_seats
  end
end
