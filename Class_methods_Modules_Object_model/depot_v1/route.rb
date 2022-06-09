class Route
  include InstanceCounter
  attr_reader :stations, :first_station, :last_station         # это нужно для метода accept_route класса Train # Может выводить список всех станций по-порядку от начальной до конечной. last_station используется в меню

  def initialize(first_station, last_station)
    @first_station = first_station
    @last_station = last_station
    @stations = [first_station, last_station]
    register_instance
  end

  def all_stations_names
    st_names = []
    self.stations.each { |st| st_names << (st.name + " ") }
    st_names.each { |name| print name }
  end

  def add_station(station)                     # Может добавлять промежуточную станцию в список
    @stations.insert(1, station)                # добавляем промежуточную станцию после первой и перед последней
  end

  def delete_station(station)                            # Может удалять промежуточную станцию из списка
    @stations.delete(station)                  
  end
  
end
