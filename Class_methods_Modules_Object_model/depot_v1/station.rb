# В классе Station (жд станция) создать метод класса all, который возвращает все станции (объекты), созданные на данный момент
class Station
  include InstanceCounter
  attr_reader :name, :trains                     # Может возвращать список всех поездов на станции, находящиеся в текущий момент
  @@stations = []
  
  def self.all                                  # возвращает все станции (объекты), созданные на данный момент
    @@stations
  end

  
  def initialize(name)                           # Имеет название, которое указывается при ее создании
    @name = name
    @trains = []
    @@stations << self                           # сохраняем все экземпляры класс Station в массив @@stations
    register_instance
  end

  def trains_list                                 # Вариант2 Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
    list = {}
    self.trains.each { |train| list[train.number] = train.type }
    list
  end

  # def show_trains_by_type(type)                 # вариант1 Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских               
  #   sum = @trains.count { |train| train.type == type.to_sym } 
  #   sum_with_type = {}
  #   sum_with_type[type] = sum
  #   sum_with_type
  #   # return type + " " + sum.to_s           
  # end

  def accept_train(train)
    !train_on_station?(train) ? accept_train!(train) : false    # принимаем поезда на станцию, только если такого номера поезда еще нет на станции. Если train_on_station? == false, то поезд принимаем, иначе возвращаем false
  end

  def send_train(train)                                          # удаляем поезд со станции, через обращение к private методу 
    send_train!(train)
  end

  def train_on_station?(train)
    self.trains.any? { |tr| tr.number == train.number  }
  end

  private
  
  # вынесено в private, чтобы нельзя было удалить массив @trains из объекта train, присвоив ему nil (прим. station1.trains = nil) 
  attr_writer :trains

  # был вынесен в private,  потому что к нему не должно быть доступа из клиентской части
  def accept_train!(train)                       # Может принимать поезда (по одному за раз). А именно - принимает объект класса Train в качестве аргумента
    @trains << train
  end

  # был вынесен в private,  потому что к нему не должно быть доступа из клиентской части
  def send_train!(train)                         # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
    @trains.delete(train)
  end
    
end
