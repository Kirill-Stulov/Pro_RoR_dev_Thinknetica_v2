# Класс Station (Станция):
# 		Имеет название, которое указывается при ее создании
# 		Может принимать поезда (по одному за раз)
# 		Может возвращать список всех поездов на станции, находящиеся в текущий момент
# 		Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
# 		Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).

# Класс Route (Маршрут):
# 		Имеет начальную и конечную станцию, а также список промежуточных станций. 
# 		Начальная и конечная станции указываютсся при создании маршрута, 
# 		а промежуточные могут добавляться между ними.
# 		Может добавлять промежуточную станцию в список
# 		Может удалять промежуточную станцию из списка
# 		Может выводить список всех станций по-порядку от начальной до конечной

# Класс Train (Поезд):
# 		Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов, эти данные указываются при создании экземпляра класса
# 		Может набирать скорость 
# 		Может возвращать текущую скорость 
# 		Может тормозить (сбрасывать скорость до нуля) 
# 		Может возвращать количество вагонов 
# 		Может прицеплять/отцеплять вагоны (по одному вагону за операцию, метод просто увеличивает или уменьшает количество вагонов). Прицепка/отцепка вагонов может осуществляться только если поезд не движется. 
# 		Может принимать маршрут следования (объект класса Route). 
# 		При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте.
# 		Может перемещаться между станциями, указанными в маршруте. Перемещение возможно вперед и назад, но только на 1 станцию за раз.
# 		Возвращать предыдущую станцию, текущую, следующую, на основе маршрута

class Station
  attr_accessor :trains                          # Может возвращать список всех поездов на станции, находящиеся в текущий момент
  attr_reader :name
  
  def initialize(name)                           # Имеет название, которое указывается при ее создании
    @name = name
    @trains = []
  end

  def accept_train(train)                       # Может принимать поезда (по одному за раз). А именно - принимает объект класса Train в качестве аргумента
    @train = train
    @trains << train
  end

  def show_trains_by_type(type)                                # Может возвращать список поездов на станции по типу: кол-во грузовых, пассажирских. тип передаем в качестве аргумента в метод
    return @trains.count { |train| train.type == type }            # возвращает количество поездов по типу
  end

  def send_train(train)                         # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
    @trains.delete(train)
  end
    
end

class Train
  attr_reader :number, :type, :vagons, :speed, :current_station       # используется в классе Station, метод accept_train -> строка puts "Train ##{train.number} ... # инстанс переменная @current_station нужна для метода accept_route 

  def initialize(number, type, vagons)          # Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов, эти данные указываются при создании экземпляра класса
    @number = number
    @type = type
    @vagons = vagons
    @speed = 0
    @tr_route = nil                                # Переменная tr_route будет хранить станции маршрута, который поезд принял в методе accept_route; нужно для использования в методе next_station, prev_station
  end

  def increase_speed(num)                       # Может набирать скорость
    @speed += num
  end 

  def stop_train                               # Может тормозить (сбрасывать скорость до нуля)
    @speed = 0
  end

  def add_wagons                               # Может прицеплять вагоны
    if self.speed != 0
      puts "Train must be stopped first!"
    else
      @vagons += 1
      return @vagons
    end
  end

  def delete_wagons                            # Может прицеплять/отцеплять вагоны (по одному вагону за операцию, метод просто увеличивает или уменьшает количество вагонов). Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
    if self.speed != 0
      puts "Train must be stopped first!"
    elsif @vagons == 0
      puts "There is already no wagons attached!"
    else      
      @vagons -= 1
      return @vagons
    end
  end

  def accept_route(route)                            # Может принимать маршрут следования (объект класса Route).          
    @current_station = route.stations[0]               # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте
    @tr_route = route.stations                          # сохраняем массив всех станций маршрута в инстанс переменную @tr_route, она нужна для метода next_station 
  end
    
  def next_station                                         # Может перемещаться между станциями, указанными в маршруте. Перемещение возможно вперед и назад, но только на 1 станцию за раз.
    next_st_index = @tr_route.index(@current_station) + 1   # вычисляем индекс следующей станции, для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1 
    if next_st_index <= @tr_route.length - 1                 # проверяем, что счетчик индекса не превысил количесво станций в маршруте. -1 нужен потому ка кинексы считатеся с 0, а length выдает сумму Элементов
      @current_station = @tr_route[next_st_index]              # перезаписываем значение инстанс переменной на следущую по индексу станцию в маршруте
    end
  end

  def prev_station                                         
    prev_st_index = @tr_route.index(@current_station) - 1   # вычисляем индекс предыдущей станции, для этого находим индекс текущей станции в массиве станций @tr_route и отнимаем 1 
    if prev_st_index >= 0                                     # проверяем, что счетчик индекса не меньшне индекса первой станций в маршруте
      @current_station = @tr_route[prev_st_index]              
    end
  end

  def show_next_station                                     # может возвращать следующую станцию, на основе маршрута
    next_st_index = @tr_route.index(@current_station) + 1   # вычисляем индекс следующей станции, для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1 
    next_station = @tr_route[next_st_index]              # вычисляем по индексу следующую станцию в маршруте
    return next_station.name
  end

  def show_prev 
    prev_st_index = @tr_route.index(@current_station) - 1
    prev_station = @tr_route[prev_st_index]
    return prev_station.name
  end

  def show_current_station                                  # текущую станцию может возвращать и через attr_reader, этот метод не обязателен
    return @current_station.name
  end

end

class Route
  attr_reader :stations       # это нужно для метода accept_route класса Train # Может выводить список всех станций по-порядку от начальной до конечной

  def initialize(first, last)
    @first = first
    @last = last
    @stations = [@first, @last]
  end

  def add_station(station)                     # Может добавлять промежуточную станцию в список
    @stations.insert(1, station)                # добавляем промежуточную станцию после первой и перед последней
  end

  def delete_station(station)                            # Может удалять промежуточную станцию из списка
    @stations.delete(station)                  
  end
  
end

# station1 = Station.new("Tash")
# station2 = Station.new("Piter")
# station3 = Station.new("Vasyuki")
# station4 = Station.new("Belgrad")
# train1 = Train.new(1, "passenger", 6)
# train2 = Train.new(2, "cargo", 12)
# train3 = Train.new(3, "passenger", 23)
# train4 = Train.new(4, "passenger", 12)


# station1.accept_train(train1)
# station1.accept_train(train2)
# station1.accept_train(train3)
# station1.trains
# station1.show_trains_by_type("passenger")
# station1.send_train(3)

# route1 = Route.new(station1, station2)
# route1.add_station(station4)
# route1.delete_station(station4)
# train1.accept_route(route1)
# train1.show_current_station
