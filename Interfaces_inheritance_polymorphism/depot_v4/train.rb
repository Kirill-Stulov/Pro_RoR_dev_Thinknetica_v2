# Разделить поезда на два типа PassengerTrain и CargoTrain, сделать родителя для классов, который будет содержать общие методы и свойства

class Train
  attr_reader :number, :type, :wagons, :speed, :current_station       # используется в классе Station, метод accept_train -> строка puts "Train ##{train.number} ... # инстанс переменная @current_station нужна для метода accept_route 

  def initialize(number)          # Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов, эти данные указываются при создании экземпляра класса
    @number = number
    @type = type
    @wagons = []
    @speed = 0
    @tr_route = nil                                # Переменная tr_route будет хранить станции маршрута, который поезд принял в методе accept_route; нужно для использования в методе next_station, prev_station
  end

  def show_next_station                                     # может возвращать следующую станцию, на основе маршрута
    next_st_index = @tr_route.stations.index(@current_station) + 1   # вычисляем индекс следующей станции, для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1 
    @tr_route.stations[next_st_index]                          # вычисляем по индексу следующую станцию в маршруте и возвращаем ее
  end

  def show_prev_station 
    prev_st_index = @tr_route.stations.index(@current_station) - 1
    @tr_route.stations[prev_st_index]
  end

  def increase_speed(num)                       # Может набирать скорость
    @speed += num
  end 

  def stop_train                                # Может тормозить (сбрасывать скорость до нуля)
    @speed = 0 if self.speed > 0
  end 

  def add_wagon(wagon)  # метод добавления вагона к поезду
    @wagons << wagon if (@speed == 0) && (wagon.type == self.type) #  К пассажирскому поезду можно прицепить только пассажирские, к грузовому - грузовые. И только если поезд стоит
  end

  def delete_wagon(wagon)
    if self.speed != 0                          # Отцеплять вагоны от поезда    . Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
      puts "Train must be stopped first!"
    elsif @wagons == 0
      puts "There is already no wagons attached!"
    else      
      @wagons.delete(wagon)
    end
  end

  # !!!нужно продумать добавление и удаление поезда из массива поездов текущей станции!!!
  def accept_route(route)                            # Может принимать маршрут следования (объект класса Route).          
    @current_station = route.first_station            # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте
    @tr_route = route                                   # сохраняем массив всех станций маршрута в инстанс переменную @tr_route, она нужна для метода next_station 
    route.first_station.trains << self                # этот поезд должен добавляться в массив @trains объекта станции
  end

  def next_station                                         # Может перемещаться между станциями, указанными в маршруте. Перемещение возможно вперед и назад, но только на 1 станцию за раз.
    next_st_index = @tr_route.stations.index(@current_station) + 1   # вычисляем индекс следующей станции, для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1 
    if next_st_index <= @tr_route.stations.length - 1                 # проверяем, что счетчик индекса не превысил количесво станций в маршруте. -1 нужен потому ка кинексы считатеся с 0, а length выдает сумму Элементов
      @current_station = @tr_route.stations[next_st_index]              # перезаписываем значение инстанс переменной на следущую по индексу станцию в маршруте
    end
  end

  def prev_station                                         
    prev_st_index = @tr_route.stations.index(@current_station) - 1   # вычисляем индекс предыдущей станции, для этого находим индекс текущей станции в массиве станций @tr_route и отнимаем 1 
    if prev_st_index >= 0                                     # проверяем, что счетчик индекса не меньшне индекса первой станций в маршруте
      @current_station = @tr_route.stations[prev_st_index]              
    end
  end

end
