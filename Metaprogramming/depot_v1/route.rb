# frozen_string_literal: true

# route class, has no child classes - creates route instances,
#   which contains two stations by default - firs and last
class Route
  include InstanceCounter
  include Validation

  STNAME_FORMAT = /^[a-z]{1,3}$/i.freeze

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
    validate2!(STNAME_FORMAT)
    register_instance
    # 2. а потом уже кладем в хеш инстанс переменной уровня класса @routes
    #   из модуля InstanceCounter, иначе (если routes_collect будет перед валидацией)
    #   валидация будет натыкаться на этот же первый объект.
    routes_collect
  end

  # метод возвращает true, если станции с таким названием уже существуют, а именно
  #   all_stations тут - это инстанс переменная уровня класса @all_stations из модуля InstanceCounter
  def self.existing_fs?(first_station)
    Station.all_stations.any? { |st| st.name == first_station }
  end

  def self.existing_ls?(last_station)
    Station.all_stations.any? { |st| st.name == last_station }
  end

  # метод возвращает true, если существует маршрут с такими станциями (первой и последней)
  def self.existing_route?(obj_stations)
    Route.all_routes.any? { |_k, v| v.stations == obj_stations }
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
end
