# frozen_string_literal: true

# train class, has two child classes - cargo_train & passenger_train
class Train
  include Manufacturer
  include InstanceCounter
  # include Accessors
  extend Accessors
  include Validation

  # сохраняем в константу шаблон номера поезда...
  #   формат номера поезда: три буквы или цифры в любом порядке ([a-z0-9]{3}),
  #   необязательный дефис (-*) (может быть, а может нет) и еще 2 буквы или цифры после дефиса [a-z0-9]{2}.
  #   ^ - начало строки; $ - конец строки; /i модификатор убирает чувствительность к регистру
  TR_NUMBER = /^[a-z0-9]{3}-*[a-z0-9]{2}$/i.freeze

  # используется в классе Station, метод accept_train -> строка puts "Train ##{train.number}
  #   инстанс переменная @current_station нужна для метода accept_route
  # attr_reader :number, :type, :wagons, :speed, :current_station, :manufacturer
  # attr_accessor :options

  # метод из модуля Accessors, динамически создает геттеры и сеттеры
  #  для аттрибутов поезда - number, type и тд.
  attr_accessor_with_history :number, :type, :wagons, :speed, :current_station, :manufacturer, :options

  # метод из модуля Accessors
  strong_attr_accessor :speed, Integer

  def self.all
    Train.all_trains
  end

  # метод класса - find, принимает номер поезда (указанный при его создании) и возвращает
  #   объект поезда по номеру или nil, если поезд с таким номером не найден. (переделан под идиому 12)
  def self.find(num)
    Train.all_trains.find { |tr| tr.number == num }
  end

  # переделал initialize метод согласно идиоме 12, теперь все параметры сохраняются в хеш options
  #   см. ИДИОМА 12 "передача переменного количества аргументов в метод" -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
  def initialize(number, options = {})
    # тут self.number, а не @number,
    #  потому что теперь используем динамический сеттер метода attr_accessor_with_history
    self.number = number
    @wagon_nums = 0
    @options = options
    options[:wagons] = []
    # тоже что self.number, но тут оставили запись значения в хеш,
    #  скорость по умолчанию = 0
    self.speed = options[:speed] || 0
    # где tr_route это ключ, а значение не присваивается при создании и по умолчанию не выставлено и будет равно nil
    options[:tr_route] = []
    options[:manufacturer] ||= 'RJD'
    # validate!
    validate2!(TR_NUMBER)
    trains_collect
    register_instance
  end

  # метод принимает блок и проходит по всем вагонам поезда
  #  используется в интерфейсе в методе хелпере train_details
  def train_detail(&block)
    # здесь начинаем перебирать вагоны и вызываем блок через yield,
    #   блок передается методу train_detail при его вызове в интерфейсе.
    #   В переменную wagon попадает вагон из массива @wagons.
    #   В самом блоке реализован вывод в зависимости от типа вагона - занятые места, или занятый объем
    #   options[:wagons].each { |wagon| yield(wagon) }
    #   эта запись делает тоже что и выше через yield, но оптимальнее
    #   см. ИДИОМА 7 Proc. -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
    options[:wagons].each(&block)
  end

  # может возвращать следующую станцию, на основе маршрута
  def show_next_station
    # вычисляем индекс следующей станции
    #   для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1
    next_st_index = @tr_route.stations.index(@current_station) + 1
    # вычисляем по индексу следующую станцию в маршруте и возвращаем ее
    @tr_route.stations[next_st_index]
  end

  def show_prev_station
    prev_st_index = @tr_route.stations.index(@current_station) - 1
    @tr_route.stations[prev_st_index]
  end

  # Может набирать скорость (переделан под идиому 12)
  def increase_speed(num)
    options[:speed] += num
  end

  # Может тормозить (сбрасывать скорость до нуля) (метод переделан под идиому 12)
  def stop_train
    options[:speed] = 0 if options[:speed].positive?
  end

  # метод добавления вагона к поезду (переделан под идиому 12)
  #  метод добавления вагонов упрощенный, нельзя выбрать заранее созданный вагон,
  #  вагон создается сразу в момент добавления, номер вагона назначается автоматически
  #  тип вагона присваивается в зависимости от типа поезда, так что проверка типа вагона
  #  на данном этапе не имеет смысла
  def add_wagon(wagon)
    # К пассажирскому поезду можно прицепить только пассажирские, к грузовому - грузовые. И только если поезд стоит
    # options[:wagons] << wagon if options[:speed].zero? && (wagon.type == options[:type])
    options[:wagons] << wagon if speed.zero? && (wagon.type == options[:type])
  end

  # Отцеплять вагоны от поезда (переделан под идиому 12)
  def delete_wagon(wagon)
    # Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
    if options[:speed] != 0
      puts 'Train must be stopped first!'
    elsif options[:wagons].empty?
      puts 'There is already no wagons attached!'
    else
      options[:wagons].delete(wagon)
    end
  end

  # Может принимать маршрут следования (объект класса Route)
  def accept_route(route)
    # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте
    @current_station = route.first_station
    # сохраняем массив всех станций маршрута в инстанс переменную @tr_route, она нужна для метода next_station
    @tr_route = route
    # этот поезд должен добавляться в массив @trains объекта станции,
    #  для этого находим станцию среди всех экземпляров класса Station
    required_station = Station.all_stations.find { |st| st.name == route.first_station }
    #   и помещаем поезд в ее массив trains (этот поезд должен добавляться в массив @trains объекта станции)
    required_station.trains << self
  end

  # метод для next_station и prev_station
  #   возвращяет станцию, которая в зависимости от порядка в методе
  #   является станцией которую поезд покидает, либо на которую поезд прибывает
  def defined_station
    Station.all_stations.find { |st| st.name == @current_station }
  end

  # Может перемещаться между станциями, указанными в маршруте...
  #  Перемещение возможно вперед и назад, но только на 1 станцию за раз
  def next_station
    # вычисляем индекс следующей станции,
    #   для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1
    next_st_index = @tr_route.stations.index(@current_station) + 1
    # проверяем, что счетчик индекса не превысил количесво станций в маршруте
    #   -1 нужен потому как индексы считаются с 0, а length выдает сумму элементов
    #   return означает - ранний выход, если условие unless выполняется
    #   unless означает - если результат выражения 'next_st_index <= @tr_route.stations.size - 1' будет false
    return unless next_st_index <= @tr_route.stations.size - 1

    # TODO: сделать проверку, что у поезда назначен маршрут, перед тем отправлять на какую-либо станцию

    # отправляем поезд со станции которую он покидает
    defined_station.send_train(self)
    # перезаписываем значение инстанс переменной на следующую по индексу станцию в маршруте
    @current_station = @tr_route.stations[next_st_index]
    # после перезаписи @current_station, defined_station теперь станция на которую поезд прибывает
    defined_station.accept_train(self)
  end

  def prev_station
    # вычисляем индекс предыдущей станции
    #   для этого находим индекс текущей станции в массиве станций @tr_route и отнимаем 1
    prev_st_index = @tr_route.stations.index(@current_station) - 1
    # проверяем, что счетчик индекса не меньшне индекса (0) - первой станции в маршруте
    return unless prev_st_index >= 0

    # станция которую поезд покидает
    defined_station.send_train(self)
    # перезаписываем значение инстанс переменной на предыдущую по индексу станцию в маршруте
    @current_station = @tr_route.stations[prev_st_index]
    # станция на которую поезд прибывает
    defined_station.accept_train(self)
  end

  # метод возвращает true, если уже существует поезд с таким номером.
  def self.existing_train?(number)
    Train.all_trains.any? { |tr| tr.number == number }
  end
end
