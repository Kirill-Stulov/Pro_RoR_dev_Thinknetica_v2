# написать метод, который принимает блок и проходит по всем поездам на станции, передавая каждый поезд в блок. 17:00 - 19:00

class Station
  include InstanceCounter
  attr_reader :name, :trains, #:stations         # Может возвращать список всех поездов на станции, находящиеся в текущий момент
  # @@stations = []
  # @stations = []
  
  def self.all                                  # возвращает все станции (объекты), созданные на данный момент. Хотя можно без этого метода, просто вызывать в интерфейсе через Station.stations, благодаря ридеру :stations в этом классе
    @stations
  end

  STNAME_FORMAT = /^[a-z]{1,3}$/i    # /^\w{1,3}$/   # сохраняем в константу шаблон имени станции. Шаблон: не менее и не более 3 букв. [a-z] Any single character in the range a-z; {1,3} - диапозон от 1 до 3 букв. ^ - начало строки; $ - конец строки;  /i модификатор убирает чувствительность к регистру
  
  def initialize(name)                           # Имеет название, которое указывается при ее создании
    @name = name
    @trains = []
    # @@stations << self                           # сохраняем все экземпляры класс Station в массив @@stations
    register_instance
    validate!                                    # выводит исключение, если аттрибут name не валидный, обрабатываем исключения и выводить сообщения пользователю в интерфейсе пользователя interface.rb, метод create_station.
    stations_collect #(new)                       # инстанс метод, добавленный мной в модуль InstanceCounter, собирает все созданные станции в массив stations, созданнй там же, это позволяет получить доступ к методу и массиву во всех классах, где подключен InstanceCounter 
  end

  def self.stations_details                             # метод принимает блок и проходит по всем станциям и поездам на них, передавая каждую станцию в блок.
    @stations.each { |station| yield(station) }                # здесь начинаем перебирать станции и вызываем блок через yield, блок передается методу station_details при его вызове в интерфейсе. В переменную station попадает станция из массива @stations. В самом блоке перебираем уже поезда
  end

  # def station_details(block)                      #метод принимает в качестве аргумента блок как объект. Блок (задан в методе интерфейса show_station_details) проходит по всем поездам @trains станции, и выводит по ним детализацию
  #   block.call(@trains)                             # вызываем именованный блок. В переменную block попадает trains_block из interface.rb (меню 14) 
  # end

  # def self.stations_details(stations, block)          #!!!! метод, который принимает в качестве аргументов массив всех станций (@stations) и блок как объект, проходит по всем поездам на станции, передавая каждый поезд в блок. 17:00 - 19:00
  #   block.call(stations)                                        # вызываем именованный блок. В переменную block попадает trains_block из interface.rb (меню 14) 
  #   # yield(st)                                          # выходим из области метода и попадаем в блок через yield, и передаем произвольное кол-во аргументов, эти аргументы попадут в блок
  # end                                                   

  def valid?                                     # публичный метод valid? для обращения к защищенному методу validate!   Метод valid? возвращает либо true, либо false
    validate!
    true
  rescue                       
    false
  end 

  def get_trains
   self.trains
  end

  def trains_list                                 # Вариант2 Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
    list = {}
    self.trains.each { |train| list[train.number] = train.type }
    list
  end

  def accept_train(train)
    !train_on_station?(train) ? accept_train!(train) : false    # принимаем поезда на станцию, только если такого номера поезда еще нет на станции. Если train_on_station? == false, то поезд принимаем, иначе возвращаем false
  end

  def send_train(train)                                          # удаляем поезд со станции, через обращение к private методу 
    send_train!(train)
  end

  def train_on_station?(train)
    self.trains.any? { |tr| tr.number == train.number }
  end

  def existing_station?                                           # метод возвращает true, если уже существует станция с таким именем.
    Station.stations.any? { |st| st.name == self.name }                #  Station.stations массив инстанс переменной уровня класса @stations из модуля InstanceCounter
  end

  private
  
  # вынесено в private, чтобы нельзя было удалить массив @trains из объекта train, присвоив ему nil (прим. station1.trains = nil) 
  attr_writer :trains

  def validate!                                                             # защищенный метод validate! проверяет валидность объекта и выбрасывает исключение в случае невалидности. Исключения из него перехватываются через rescue в интерфейсе пользователя interface.rb, метод create_station
    raise "Station name can not be empty!" if name.empty?                     # если введена пустая строка
    raise "Station name can not be less than 3 letters!" if name.length < 3   # пожалуй лишняя проверка, но оставлю, т.к несет дополнительную информацию пользователю
    raise "Station name wrong format!" if name !~ STNAME_FORMAT               # если введенное имя станции не соответствует требуемому шаблону
    raise "This stations is already exist!" if existing_station?              # если станция с таким именем уже существует
  end

  # был вынесен в private,  потому что к нему не должно быть доступа из клиентской части
  def accept_train!(train)                       # Может принимать поезда (по одному за раз). А именно - принимает объект класса Train в качестве аргумента
    @trains << train
  end

  # был вынесен в private,  потому что к нему не должно быть доступа из клиентской части
  def send_train!(train)                         # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
    @trains.delete(train)
  end
end
