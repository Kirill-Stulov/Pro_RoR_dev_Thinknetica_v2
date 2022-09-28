# Для пассажирских вагонов:
# 	• Добавить атрибут общего кол-ва мест (задается при создании вагона) - добавил аттрибут total_free_seats
# 	• Добавить метод, который "занимает места" в вагоне (по одному за раз) - добавил метод occupy_seat
# 	• Добавить метод, который возвращает кол-во занятых мест в вагоне - добавил show_occupied_seats
# 	• Добавить метод, возвращающий кол-во свободных мест в вагоне. - добавил show_free_seats

class PassengerWagon < Wagon
  attr_reader :max_seats

  def initialize(number)
    super
    @type = :passenger
    @max_seats = 62                                   # общее кол-во мест в вагоне
    @total_free_seats = @max_seats                    # оставшиеся свободные места в вагоне. На момент создания вагона это кол-во равно общему кол-ву мест - @initial_seats
  end

  def occupy_seat                                         # занимает места в вагоне (по одному за раз)
    raise "All seats are off!" if @total_free_seats == 0  # выбрасываем исключение, если свободных мест в этом вагоне уже нет
    @total_free_seats -= 1
  end

  def show_occupied_seats                                 # считает и возвращает количество занятых мест в вагоне
    @max_seats - @total_free_seats                        # кол-во занятых мест равно изначальное количество минус кол-во свободных мест.
  end

  def show_free_seats                                     # возвращает кол-во свободных мест в вагоне
    @total_free_seats
  end
end
