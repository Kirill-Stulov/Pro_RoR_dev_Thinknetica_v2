# frozen_string_literal: true

# route class, has no child classes - creates route instances,
#   which contains two stations by default - firs and last
class Route
  include InstanceCounter

  # это нужно для метода accept_route класса Train #
  #   Может выводить список всех станций по-порядку от начальной до конечной.
  #   last_station используется в меню
  attr_reader :stations, :first_station, :last_station

  def self.show_stations_in_station_class
    Station.stations
  end

  def initialize(first_station, last_station)
    @first_station = first_station
    @last_station = last_station
    @stations = [first_station, last_station]
    # 1. сначала валидация
    validate!
    register_instance
    # 2. а потом уже кладем в хеш инстанс переменной уровня класса @routes
    #   из модуля InstanceCounter, иначе (если routes_collect будет перед валидацией)
    #   валидация будет натыкаться на этот же первый объект.
    routes_collect
  end

  def valid?
    validate!
    true
  rescue ValidationError
    false
  end

  # метод возвращает true, если станции с таким названием уже существуют, а именно
  #   stations тут - это инстанс переменная уровня класса @stations из модуля InstanceCounter
  def existing_first_station?
    Station.stations.any? { |st| st.name == (first_station) }
  end

  def existing_last_station?
    Station.stations.any? { |st| st.name == (last_station) }
  end

  # метод возвращает true, если существует маршрут с такими станциями (первой и последней)
  # TODO: теперь все маршруты хранятся в хеше, а не в массиве, этот метод нужно переделать под проверку в хеше!!!
  #  ИНАЧЕ СЕЙЧАС ЭТА ПРОВЕРКА НЕ РАБОТАЕТ!!!
  def existing_route?
    # Route.routes.any? { |route| route == stations }
    Route.routes.any? { |_k, v| v.stations == stations }
  end

  # Может добавлять промежуточную станцию в список
  #   добавляем промежуточную станцию после первой и перед последней
  def add_station(station)
    @stations.insert(1, station)
  end

  # Может удалять промежуточную станцию из списка
  def delete_station(station)
    @stations.delete(station)
  end

  private

  # защищенный метод validate! проверяет валидность объекта
  #   и выбрасывает исключение в случае невалидности.
  #   Исключения из него перехватываются через rescue
  #   в интерфейсе пользователя interface.rb, метод create_edit_route
  def validate!
    # если ввод пуст
    # raise "Station name can not be empty!" if first_station.nil?#(first_station || last_station).empty?
    # если existing_station равно false. Если такой станции не существует (либо ввод пуст).
    #   На формат ввода проверять не нужно, т.к это делается когда имя станции создается,
    #   здесь пользователю дозволяется ввести только имя существующей станции
    #   (все имена хранятся в локальном массиве @stations класса interface)
    raise 'Non existing or empty first station name entered!' unless existing_first_station?
    raise 'Non existing or empty last station name entered!' unless existing_last_station?
    # если такой маршрут уже есть, выбрасываем исключение
    raise 'This route is alredy exists!' if existing_route?
  end
end
