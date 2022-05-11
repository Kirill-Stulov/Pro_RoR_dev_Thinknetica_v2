class Route
  attr_reader :stations, :first_station, :last_station         # это нужно для метода accept_route класса Train # Может выводить список всех станций по-порядку от начальной до конечной. last_station используется в меню

  def initialize(first_station, last_station)
    @first_station = first_station
    @last_station = last_station
    @stations = [first_station, last_station]
  end

  def all_stations_names
    st_names = []
    self.stations.each { |st| st_names << (st.name + " ") }
    st_names.each { |name| print name }
  end

  def add_station(station)
    self.add_station!(station)
  end

  def delete_station(station)
    self.delete_station!(station)
  end

  protected 

  # был вынесен в protected,  потому что к нему не должно быть доступа из клиентской части. Хотя тут все равно только attr_reader
  def add_station!(station)                     # Может добавлять промежуточную станцию в список
    @stations.insert(1, station)                # добавляем промежуточную станцию после первой и перед последней
  end

  # был вынесен в protected,  потому что к нему не должно быть доступа из клиентской части
  def delete_station!(station)                            # Может удалять промежуточную станцию из списка
    @stations.delete(station)                  
  end
  
end
