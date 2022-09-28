# Написать метод, который принимает блок и проходит по всем вагонам поезда (вагоны должны быть во внутреннем массиве), 
# передавая каждый объект вагона в блок.

class Train
  include Manufacturer
  include InstanceCounter
  attr_reader :number, :type, :wagons, :speed, :current_station, :manufacturer     # используется в классе Station, метод accept_train -> строка puts "Train ##{train.number} ... # инстанс переменная @current_station нужна для метода accept_route 
  @@trains = []

  TR_NUMBER = /^[a-z0-9]{3}-*[a-z0-9]{2}$/i     # сохраняем в константу шаблон номера поезда. Формат номера поезда: три буквы или цифры в любом порядке ([a-z0-9]{3}), необязательный дефис (-*) (может быть, а может нет) и еще 2 буквы или цифры после дефиса [a-z0-9]{2}. ^ - начало строки; $ - конец строки; /i модификатор убирает чувствительность к регистру

  def initialize(number)                        # Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов, эти данные указываются при создании экземпляра класса
    @number = number
    @type = type
    @wagons = []
    @speed = 0
    @tr_route = nil                                # Переменная tr_route будет хранить станции маршрута, который поезд принял в методе accept_route; нужно для использования в методе next_station, prev_station
    @manufacturer = nil
    validate!                                       # валидация должна быть до того как кладем в массив
    @@trains << self
    register_instance
  end

  def train_details                               # метод принимает блок и проходит по всем вагонам поезда
    @wagons.each { |wagon| yield(wagon) }           # здесь начинаем перебирать вагоны и вызываем блок через yield, блок передается методу train_details при его вызове в интерфейсе. В переменную wagon попадает вагон из массива @wagons. В самом блоке реализован вывод в зависимости от типа вагона - занятые месте, или занятый объем 
  end

  def self.all  
    @@trains
  end

  def valid?
    validate!
    true
  rescue
    false
  end

  # def show_wags_nums
  #   self.wagons.each { |wag| wag.number }
  # end

  def self.find(num)                               # метод класса find, принимает номер поезда (указанный при его создании) и возвращает объект поезда по номеру или nil, если поезд с таким номером не найден.
    @@trains.find { |tr| tr.number == num }
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
    elsif @wagons.empty?
      puts "There is already no wagons attached!"
    else      
      @wagons.delete(wagon)
    end
  end

  # !!!нужно продумать добавление и удаление поезда из массива поездов текущей станции!!!
  def accept_route(route)                            # Может принимать маршрут следования (объект класса Route).          
    @current_station = route.first_station            # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте
    @tr_route = route                                   # сохраняем массив всех станций маршрута в инстанс переменную @tr_route, она нужна для метода next_station 
    # этот поезд должен добавляться в массив @trains объекта станции, для этого находим станцию среди всех экземпляров класса Station и помещаем поезд в ее массив trains 
    required_station = Station.stations.find { |st| st.name == route.first_station }
    required_station.trains << self                       # этот поезд должен добавляться в массив @trains объекта станции
    # route.first_station.trains << self                
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

  def existing_train?                                         # метод возвращает true, если уже существует станция с таким именем.
    @@trains.any? { |tr| tr.number == self.number }
  end

  private

  def validate!                                     # защищенный метод validate! проверяет валидность объекта и выбрасывает исключение в случае невалидности. Исключения из него перехватываются через rescue в интерфейсе пользователя interface.rb, метод create_train
    raise "Train number can not be empty!" if number.empty?                 # если введена пустая строка
    raise "Train number wrong format!" if number !~ TR_NUMBER               # если введенный номер поезда не соответствует требуемому шаблону
    raise "This train number is alredy exists!" if existing_train?          # если поезд с таким номером уже существует    
    # тип проверять не нужно, в интерфейсе это строго разделено на 1 и 2
  end
end
