class Route
  include InstanceCounter
  attr_reader :stations, :first_station, :last_station         # это нужно для метода accept_route класса Train # Может выводить список всех станций по-порядку от начальной до конечной. last_station используется в меню
  @@stations = []
  
  def initialize(first_station, last_station)
    @first_station = first_station
    @last_station = last_station
    @stations = [first_station, last_station]
    validate!                                       #1. сначала валидация
    register_instance
    @@stations << self.stations                       # вместо этого в дальнейшем нужно будет использвать routes_collect
    # routes_collect    # (new)                     2.  а потом уже кладем в массив инстанс переменной уровня класса @routes из модуля InstanceCounter, иначе (если routes_collect будет перед валидацией) валидация будет натыкаться на этот же первый объект.  !!!этот метод нужно ипользовать вместо @@stations (нужно использвать этот метод, чтобы работало как в классе station.)!!!
  end

  def valid?
    validate!
    true
  rescue
    false
  end

  def self.show_stations_in_station_class #(new)
    Station.stations
  end

  def existing_first_station?                                   # метод возвращает true, если станции с таким названием уже существуют, а именно 
    Station.stations.any? { |st| st.name == (first_station) }   # stations тут - это инстанс переменная уровня класса @stations из модуля InstanceCounter
  end

  def existing_last_station?
    Station.stations.any? { |st| st.name == (last_station) }
  end

  def existing_route?                                            # метод возвращает true, если существует маршрут с такими станциями (первой и последней)  
    (self.stations - @@stations.flatten).empty?                   # используем переменную класса @@stations. flatten нужен, чтобы избавиться от массива в массиве и получить просто массив, из известного массива [self.stations] вычитаем второй массив и если после этого известный массив становится пустым, значит его значения содержались во втором массиве)  
    # Route.routes.each do |rt|
    #   (self.stations - rt.stations.flatten).empty?
    # end
  end

  # def all_stations_names                                    # этот метод не нужен (использовался в интерфейсе - create route), чтобы получить в интерфейсе все станции из маршрута - достаточно вызывать route.stations
  #   self.stations
  # end

  # def all_stations_names                                    # заменен на метод выше
  #   st_names = []
  #   self.stations.each { |st| st_names << (st.name + " ") }
  #   st_names.each { |name| print name }
  # end

  def add_station(station)                     # Может добавлять промежуточную станцию в список
    @stations.insert(1, station)                # добавляем промежуточную станцию после первой и перед последней
  end

  def delete_station(station)                            # Может удалять промежуточную станцию из списка
    @stations.delete(station)                  
  end

  private

  def validate!                                                                                               # защищенный метод validate! проверяет валидность объекта и выбрасывает исключение в случае невалидности. Исключения из него перехватываются через rescue в интерфейсе пользователя interface.rb, метод create_edit_route 
    # raise "Station name can not be empty!" if first_station.nil?#(first_station || last_station).empty?        # если ввод пуст
    raise "Non existing or empty first station name entered!" if !existing_first_station?                         # если existing_station равно false. Если такой станции не существует (либо ввод пуст). На формат ввода проверять не нужно, т.к это делается когда имя станции создается, здесь пользователю дозволяется ввести только имя существующей станции (все имена хранятся а локальном массиве @stations класса interface) 
    raise "Non existing or empty last station name entered!" if !existing_last_station?
    raise "This route is alredy exists!" if existing_route?                                                       # если такой маршрут уже есть, выбрасываем исключение
  end
end
