# frozen_string_literal: true

# train class, has two child classes - cargo_train & passenger_train
class Train
  include Manufacturer
  include InstanceCounter

  # сохраняем в константу шаблон номера поезда...
  #   формат номера поезда: три буквы или цифры в любом порядке ([a-z0-9]{3}),
  #   необязательный дефис (-*) (может быть, а может нет) и еще 2 буквы или цифры после дефиса [a-z0-9]{2}.
  #   ^ - начало строки; $ - конец строки; /i модификатор убирает чувствительность к регистру
  TR_NUMBER = /^[a-z0-9]{3}-*[a-z0-9]{2}$/i.freeze

  # используется в классе Station, метод accept_train -> строка puts "Train ##{train.number}
  #   инстанс переменная @current_station нужна для метода accept_route
  attr_reader :number, :type, :wagons, :speed, :current_station, :manufacturer
  attr_accessor :options

  def self.all
    Train.trains
  end

  # метод класса find, принимает номер поезда (указанный при его создании) и возвращает
  #   объект поезда по номеру или nil, если поезд с таким номером не найден. (переделан под идиому 12)
  def self.find(num)
    Train.trains.find { |tr| tr.number == num }
  end

  # Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов,
  #   эти данные указываются при создании экземпляра класса
  # def initialize(number)
  #   @number = number
  #   @type = type
  #   @wagons = []
  #   @speed = 0
  # Переменная tr_route будет хранить станции маршрута, который поезд принял
  #   в методе accept_route; нужно для использования в методе next_station, prev_station
  #   @tr_route = nil
  # через идимому ||= задаем дефолтное значение производителя
  #   @manufacturer ||= 'RJD'
  #   validate! # валидация должна быть до того как кладем в массив
  #   trains_collect
  ##   @@trains << self #!! это больще не нужно, т.к есть метод trains_collect
  #   register_instance
  # end

  # переделал initialize метод согласно идиоме 12, теперь все параметры сохраняются в хеш options
  #   см. ИДИОМА 12 "передача переменного количества аргументов в метод" -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
  def initialize(number, options = {})
    @number = number
    @wagon_nums = 0
    @options = options
    options[:wagons] = []
    options[:speed] = 0
    # где tr_route это ключ, а значение не присваивается при создании и по умолчанию не выставлено и будет равно nil
    options[:tr_route] = []
    options[:manufacturer] ||= 'RJD'
    validate!
    trains_collect
    register_instance
  end

  # метод принимает блок и проходит по всем вагонам поезда
  def train_details(&block)
    # здесь начинаем перебирать вагоны и вызываем блок через yield,
    #   блок передается методу train_details при его вызове в интерфейсе.
    #   В переменную wagon попадает вагон из массива @wagons.
    #   В самом блоке реализован вывод в зависимости от типа вагона - занятые места, или занятый объем
    #   options[:wagons].each { |wagon| yield(wagon) }
    #   эта запись делает тоже что и выше через yield, но оптимальнее
    #   см. ИДИОМА 7 Proc. -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
    options[:wagons].each(&block)
  end

  def valid?
    validate!
    true
  rescue ValidationError
    false
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
  #  метод добавления вагонов урощенный, нельзя выбрать заранее созданный вагон, 
  #  вагон создается сразу в момент добавления, номер вагона назначается автоматически
  #  тип вагона присваивается в зависимости от типа поезда, так что проверка типа вагона
  #  на данном этапе не имеет смысла
  def add_wagon(wagon)
    # К пассажирскому поезду можно прицепить только пассажирские, к грузовому - грузовые. И только если поезд стоит
    options[:wagons] << wagon if options[:speed].zero? && (wagon.type == options[:type])
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

  # TODO: нужно продумать добавление и удаление поезда из массива поездов текущей станции!!!
  #   Может принимать маршрут следования (объект класса Route)
  def accept_route(route)
    # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте
    @current_station = route.first_station
    # сохраняем массив всех станций маршрута в инстанс переменную @tr_route, она нужна для метода next_station
    @tr_route = route
    # этот поезд должен добавляться в массив @trains объекта станции,
    #   для этого находим станцию среди всех экземпляров класса Station
    required_station = Station.stations.find { |st| st.name == route.first_station }
    #   и помещаем поезд в ее массив trains (этот поезд должен добавляться в массив @trains объекта станции)
    required_station.trains << self
    # route.first_station.trains << self
  end

  # Может перемещаться между станциями, указанными в маршруте...
  # ...Перемещение возможно вперед и назад, но только на 1 станцию за раз
  def next_station
    # вычисляем индекс следующей станции,
    #   для этого находим индекс текущей станции в массиве станций @tr_route и добавляем 1
    next_st_index = @tr_route.stations.index(@current_station) + 1
    # проверяем, что счетчик индекса не превысил количесво станций в маршруте
    #   -1 нужен потому как индексы считаются с 0, а length выдает сумму элементов
    #   return означает - ранний выход, если условие unless выполняется
    #   unless означает - если результат выражения 'next_st_index <= @tr_route.stations.size - 1' будет false
    return unless next_st_index <= @tr_route.stations.size - 1

    # перезаписываем значение инстанс переменной на следущую по индексу станцию в маршруте
    @current_station = @tr_route.stations[next_st_index]
  end

  def prev_station
    # вычисляем индекс предыдущей станции
    #   для этого находим индекс текущей станции в массиве станций @tr_route и отнимаем 1
    prev_st_index = @tr_route.stations.index(@current_station) - 1
    # проверяем, что счетчик индекса не меньшне индекса (0) - первой станции в маршруте
    return unless prev_st_index >= 0

    @current_station = @tr_route.stations[prev_st_index]
  end

  # метод возвращает true, если уже существует станция с таким именем.
  def existing_train?
    Train.trains.any? { |tr| tr.number == number }
  end

  private

  # защищенный метод validate! проверяет валидность объекта и выбрасывает исключение в случае невалидности
  #   Исключения из него перехватываются через rescue в интерфейсе пользователя interface.rb, метод create_train
  def validate!
    # если введена пустая строка
    raise 'Train number can not be empty!' if number.empty?
    # если введенный номер поезда не соответствует требуемому шаблону
    raise 'Train number wrong format!' if number !~ TR_NUMBER
    # если поезд с таким номером уже существует
    raise 'This train number is alredy exists!' if existing_train?
    # тип проверять не нужно, в интерфейсе это строго разделено на 1 и 2
  end
end
