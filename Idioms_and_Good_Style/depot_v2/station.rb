# frozen_string_literal: true

# station class, has no child classes - creates station instances, which contains trains
class Station
  include InstanceCounter

  # сохраняем в константу шаблон имени станции.
  #   Шаблон: не менее и не более 3 букв. [a-z] Any single character in the range a-z;
  #   {1,3} - диапозон от 1 до 3 букв. ^ - начало строки; $ - конец строки;
  #   /i модификатор убирает чувствительность к регистру
  STNAME_FORMAT = /^[a-z]{1,3}$/i.freeze

  # Может возвращать список всех поездов на станции, находящиеся в текущий момент
  attr_reader :name, :trains

  # возвращает все станции (объекты), созданные на данный момент.
  #   Хотя можно без этого метода, просто вызывать в интерфейсе через Station.stations,
  #   благодаря ридеру :stations в этом классе
  def self.all
    @stations
  end

  # т.к в этом методе нужно пройтись и по станциям и по поездам на них,
  #   то перебираем станции а внутри блока перебираем поезда
  #   метод принимает блок и проходит по всем станциям и поездам на них, передавая каждую станцию в блок.
  #   во второй строке начинаем перебирать станции и вызываем блок через yield,
  #   блок передается методу station_details при его вызове в интерфейсе.
  #   В переменную station попадает станция из массива @stations. В самом блоке перебираем уже поезда
  def self.stations_details(&block)
    @all_stations.each(&block)
    # @stations.each { |station| yield(station) }
  end

  # станция имеет название, которое указывается при ее создании
  def initialize(name)
    @name = name.capitalize
    @trains = []
    register_instance
    # validate! выводит исключение, если аттрибут name не валидный,
    #   обрабатываем исключения и выводим сообщения пользователю
    #   в интерфейсе пользователя interface.rb, метод create_station.
    validate!
    # stations_collect - инстанс метод, добавленный мной в модуль InstanceCounter,
    #   собирает все созданные станции в массив stations, созданный там же,
    #   это позволяет получить доступ к методу и массиву во всех классах,
    #   где подключен InstanceCounter
    stations_collect
  end

  # публичный метод valid? для обращения к защищенному методу validate!
  #   метод valid? возвращает либо true, либо false
  def valid?
    validate!
    true
  rescue ValidationError
    false
  end

  # get trains method - not in use
  def g_trains
    trains
  end

  # Вариант2 Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
  def trains_list
    list = {}
    trains.each { |train| list[train.number] = train.options[:type] }
    list
  end

  # принимаем поезда на станцию, только если такого номера поезда еще нет на станции
  #   Если train_on_station? == false, то поезд принимаем, иначе возвращаем false
  def accept_train(train)
    !train_on_station?(train) ? accept_train!(train) : false
  end

  # удаляем поезд со станции, через обращение к private методу
  def send_train(train)
    send_train!(train)
  end

  def train_on_station?(train)
    trains.any? { |tr| tr.number == train.number }
  end

  # метод возвращает true, если уже существует станция с таким именем.
  def existing_station?
    # Station.stations массив инстанс переменной уровня класса @stations из модуля InstanceCounter
    Station.all_stations.any? { |st| st.name == name }
  end

  private

  # вынесено в private, чтобы нельзя было удалить массив @trains из объекта train,
  #   присвоив ему nil (прим. station1.trains = nil)
  attr_writer :trains

  # защищенный метод validate! проверяет валидность объекта и выбрасывает исключение в случае невалидности.
  #   Исключения из него перехватываются через rescue в интерфейсе пользователя interface.rb, метод create_station
  def validate!
    # если введена пустая строка
    raise 'Station name can not be empty!' if name.empty?
    # пожалуй лишняя проверка, но оставлю, т.к несет дополнительную информацию пользователю
    raise 'Station name can not be less than 3 letters!' if name.length < 3
    # если введенное имя станции не соответствует требуемому шаблону
    raise 'Station name wrong format!' if name !~ STNAME_FORMAT
    # если станция с таким именем уже существует
    raise 'This station is already exist!' if existing_station?
  end

  # был вынесен в private,  потому что к нему не должно быть доступа из клиентской части
  # Может принимать поезда (по одному за раз). А именно - принимает объект класса Train в качестве аргумента
  def accept_train!(train)
    @trains << train
  end

  # был вынесен в private,  потому что к нему не должно быть доступа из клиентской части
  # Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def send_train!(train)
    @trains.delete(train)
  end
end
