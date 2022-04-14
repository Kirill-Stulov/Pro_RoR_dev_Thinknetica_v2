# Текущая проблема:
# у меня когда поезд принимает маршрут (метод accept_route класса Train), то он не удаляется со станции, 
# если до этого его приняла станция (метод accept_train класса Station), поезда храним в @trains << train, 
# хотя скорее всего стоит сделать переменную класса @@stations_and_trains и в этом хеше хранить станции с поездами

# class Depot
#   attr_accessor :st_and_tr
#   @@st_and_tr = {}                            # хранит хеши всех станций с их поездами, используется в методе accept_train класса Station
# end

class Station #< Depot
  attr_accessor :trains, :train
  attr_reader :st_name
  
  def initialize(st_name)                     # Имеет название, которое указывается при ее создании
    @st_name = st_name
    @trains = []
  end

  # accept_train версия 2, работает неверно
  # def accept_train(train)                       # Может принимать поезда (по одному за раз). А именно - примнимает объект класса Train в качестве аргумента
  #   @train = train
  #   train.current_station = self                # т.к станция принимает поезд, то @current_station поезда(объекта train) присваивается значение самой станции на которой вызывается метод accept_train, значение этой переменной класса Train меняется также в том случае, если этому объекту будет присвоен маршрут, тогда согласно заданию тпм будет первая станция в маршруте 
  #   if @@st_and_tr.empty?                                                                      #1. если это первая запись в хеш
  #     @@st_and_tr[self.st_name] = [train.number]
  #     puts "1. Train ##{train.number} arrived to station #{self.st_name} "
  #   elsif @@st_and_tr.any?{ |st, tr| st != self.st_name && !tr.include?(train.number) }    #2. если такой пары нет в хеше @@st_ans_tr нет (т.е если еще не добавлено ни одной станции с таким названием и номером поезда) 
  #     @@st_and_tr[self.st_name] = [train.number]                                            # то пишем новую пару в хеш @@st_and_tr 
  #     puts "2. Train ##{train.number} arrived to station #{self.st_name} "
  #   elsif @@st_and_tr.any?{ |st, tr| st == self.st_name && !tr.include?(train.number) }           #3. если такой ключ уже есть, а значение в паре новое (т.е если станция уже есть, но этого номера поезда у нее еще нет )
  #     @@st_and_tr[self.st_name] << train.number                                                 # то к этому ключу дописываем значение
  #     puts "3. Train ##{train.number} arrived to station #{self.st_name} "                                             
  #   elsif @@st_and_tr.any?{ |st, tr| st == self.st_name && tr.include?(train.number) }           #4. если такой ключ уже есть, и значение в нем такое тоже есть
  #     puts "4. Train ##{train.number} is already on station - #{self.st_name} "                  # то выводим что такой поезд уже есть на этой станции
  #   elsif @@st_and_tr.keys.any? {|st| st == self.st_name } && !@@st_and_tr.values.any?{ |tr| tr.include?(train.number) } # 5. Если такая станция отдельно существует в какой-либо из пар в массиве @@st_and_tr И номер поезда НЕ существует в какой-либо из пар в массиве @@st_and_tr
  #     @@st_and_tr[@station] << @number                                                                                 # то добавляем поезд @number к уже существующей станции @station. Т.к поезд новый и нигде его еще не было
  #     puts "5. Train ##{train.number} arrived to station #{self.st_name}"
  #   elsif @@st_and_tr.keys.any?{ |st| st != self.st_name } && @@st_and_tr.values.any? {|tr| tr.include?(train.number) }            #6. если такое значение есть в другой паре, (значит поезд находится на другой станции и прежде чем присваивать новой, нужно удалить с текущей)
  #     pair = @@st_and_tr.select{ |st, tr| st != self.st_name && tr.include?(train.number) }       # находим пару с этим значением
  #     @@st_and_tr.delete(pair)                                                               # удаляем пару с этим значением из хеша @@st_and_tr   
  #     @@st_and_tr[self.st_name] << train.number                                               #присваиваем поезд новой станции к этому ключу дописываем значение 
  #     puts "6. Train ##{train.number} moved to station - #{self.st_name} "
  #   end 
  # end
  
  # accept_train версия 1
  def accept_train(train)                       # Может принимать поезда (по одному за раз). А именно - принимает объект класса Train в качестве аргумента
    @train = train
    train.current_station = self
    @trains << train
    puts "Train ##{train.number} arrived to station #{self.st_name}"
  end

  def show_trains                               # Может возвращать список всех поездов на станции, находящиеся в текущий момент
    if !@trains.empty?
      @trains.each { |train| puts train.number }
    else 
      puts "No trains on station #{ self.st_name }" 
    end    
  end

  def show_trains_by_type                       # Может возвращать список поездов на станции по типу: кол-во грузовых, пассажирских
    puts "Station: #{self.st_name}"             # выводит имя текущей станции 
    puts "Number of passenger trains: #{@trains.count { |train| train.type == "passenger"} }" # выводим количество пассажирских поездов
    puts "Number of cargo trains: #{@trains.count { |train| train.type == "cargo"} }"
  end

  # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def send_train(train)
    puts "Train ##{train.number} leaved station #{self.st_name}"
    @trains.delete(train)
  end
    
end

class Train #< Depot
  attr_accessor :speed, :current_station        # инстанс переменная @current_station нужна для метода accept_route 
  attr_reader :number, :type                    # используется в классе Station, метод accept_train -> строка puts "Train ##{train.number} ...

  def initialize(number, type, vagons)          # Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов, эти данные указываются при создании экземпляра класса
    @number = number
    @type = type
    @vagons = vagons
    @speed = 0
    @tr_route = nil                                # Переменная tr_route будет хранить станции маршрута, который поезд принял в методе accept_route; нужно для использования в методе next_station, prev_station
  end

  def increase_speed(num)                       # Может набирать скорость
    @speed += num
    show_current_speed
  end 

  def show_current_speed                        # Может возвращать текущую скорость
    puts "current train speed is: #{@speed} km/h"
  end

  def stop_strain                               # Может тормозить (сбрасывать скорость до нуля)
    @speed = 0
    puts "Train is stopped!"
  end

  def show_wagons                               # Может возвращать количество вагонов
    puts "Train ##{self.number} has #{@vagons} vagons" 
  end

  def add_wagons                               # Может прицеплять
    if self.speed != 0
      puts "Train must be stopped first!"
    else
      @vagons += 1
      show_wagons
    end
  end

  def delete_wagons                            # Может прицеплять/отцеплять вагоны (по одному вагону за операцию, метод просто увеличивает или уменьшает количество вагонов). Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
    if self.speed != 0 #|| @vagons == 0
      puts "Train must be stopped first!"
    elsif @vagons == 0
      puts "There is already no wagons attached!"
    else      
      @vagons -= 1
      show_wagons
    end
  end

  # если этот метод применяется после метода accept_train класса Station, и при этом в маршруте первая станция не та, на которой был применен accept_train, 
  # то поезд на котором был вызван метод accept_route нужно удалять из массива @trains класса Station.
  # придется позже это проверять в хешах будущей переменной класса @@stations_and_trains - иначе как проверять соответствие 
  def accept_route(route)                            # Может принимать маршрут следования (объект класса Route).          
    @current_station = route.stations[0]               # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте
    @tr_route = route.stations                          # сохраняем массив всех станций маршрута в инстанс переменную @tr_route, она нужна для метода next_station 
    puts "Train ##{self.number} arrived to station #{@current_station.st_name} "
  end
    
  def next_station                                         # Может перемещаться между станциями, указанными в маршруте. Перемещение возможно вперед и назад, но только на 1 станцию за раз.
    next_st_index = @tr_route.index(@current_station) + 1   # вычисляем индекс следующей станции, для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1 
    if next_st_index <= @tr_route.length - 1                 # проверяем, что счетчик индекса не превысил количесво станций в маршруте. -1 нужен потому ка кинексы считатеся с 0, а length выдает сумму Элементов
      @current_station = @tr_route[next_st_index]              # перезаписываем значение инстанс переменной на следущую по индексу станцию в маршруте
      puts "Train ##{self.number} arrived to station #{@current_station.st_name} "
    else
      puts "Train ##{self.number} is already on the last station in route - #{@current_station.st_name} "
    end
  end

  def prev_station                                         
    prev_st_index = @tr_route.index(@current_station) - 1   # вычисляем индекс предыдущей станции, для этого находим индекс текущей станции в массиве станций @tr_route и отнимаем 1 
    if prev_st_index >= 0                                     # проверяем, что счетчик индекса не меньшне индекса первой станций в маршруте
      @current_station = @tr_route[prev_st_index]              
      puts "Train ##{self.number} arrived to station #{@current_station.st_name} "
    else
      puts "Train ##{self.number} is already on the first station in route - #{@current_station.st_name} "
    end
  end

  
  def show_required_station                      # может Возвращать предыдущую станцию, текущую, следующую, на основе маршрута
    loop do 
      puts "-- To see next station - print => next"
      puts "-- To see previous station - print => prev"
      puts "-- To see current station - print => current"
      puts "-- Print stop to exit"
      input = gets.chomp
      if input == "next"
        next_st_index = @tr_route.index(@current_station) + 1   # вычисляем индекс следующей станции, для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1 
        next_station = @tr_route[next_st_index]              # вычисляем по индексу следующую станцию в маршруте
        puts "Next station is #{next_station.st_name} "  
      elsif input == "prev"
        prev_st_index = @tr_route.index(@current_station) - 1
        prev_station = @tr_route[prev_st_index]
        puts "Previous station is #{prev_station.st_name} "
      elsif input == "current"
        puts "Current station is #{@current_station.st_name} "
      elsif input == "stop"
        break
      else
        puts "Wrong input!"
      end 
    end
  end

end

class Route
  attr_accessor :stations       # это нужно для метода accept_route класса Train

  def initialize(first, last)
    @first = first
    @last = last
    @stations = [@first, @last]
  end

  def add_station(station)                     # Может добавлять промежуточную станцию в список
    @stations.insert(1, station)                # добавляем промежуточную станцию после первой и перед последней
    puts "Station #{station.st_name} added to route!"
  end

  def delete_station                            # Может удалять промежуточную станцию из списка
    if @stations.length > 2                      # если в списке больше двух станций, то удаляем промежуточную станцию
      @stations.delete_at(1)                  
    else
      puts "There are no intermediate stations left!"
    end
  end

  def list_stations                             # Может выводить список всех станций по-порядку от начальной до конечной
    @stations.each { |station| puts station.st_name }  
  end
  
end

station1 = Station.new("Tash")
station2 = Station.new("Piter")
station3 = Station.new("Vasyuki")
station4 = Station.new("Belgrad")
train1 = Train.new(1, "passenger", 6)
train2 = Train.new(2, "cargo", 12)
train3 = Train.new(3, "passenger", 23)
train4 = Train.new(4, "passenger", 12)

route1 = Route.new(station1, station2)
train1.accept_route(route1)
train1.show_required_station
