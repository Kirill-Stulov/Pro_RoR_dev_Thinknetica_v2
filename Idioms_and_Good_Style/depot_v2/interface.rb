# frozen_string_literal: true

require_relative 'modules'
require_relative 'station'
require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'
require_relative 'route'

# module contains all methods related to stations actions
module StationsActions
  def show_stations
    # такая запись эквивалентна записи в следующей строке,
    #  но быстрее (см. ИДИОМА 7 Proc. -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
    puts Station.all_stations.map(&:name)
    # Station.stations.map{ |obj| puts obj.name }
    # puts Station.all                # выводит все экземпляры класса Station через метод класса all из Station
    # puts Station.stations #(new)    # это работает благодаря инстанс методу stations_collect из модуля InstanceCounter
    # puts Route.show_stations_in_station_class  # (new) получил доступ к данным класса Station из класса Route!
  end

  # Метод для вывода детальной информации по всем станциям и поездам на них
  def show_station_details
    puts '===== All stations in details ====='
    # передаем (не именованный) блок напрямую в метод station_details,
    #  хотя лучше выглядел первый вариант из depot, когда я передавал именованный блок через lambda
    Station.stations_details do |station|
      puts station.name
      station.trains.each do |train|
        puts "-> Train ##{train.number}; Type:#{train.options[:type]}; Vagons:#{train.options[:wagons].size}"
      end
    end
  end

  alias stationd show_station_details

  # Просматривать список станций и список поездов на станции
  def stations_and_trains
    loop do
      puts "===== Show list of stations and trains menu ===== \n"
      puts '1 -> Show list of stations'
      puts '0 -> back to main menu'
      enter = gets.chomp
      break if enter == '0'

      result = enter == '1' ? showst : 'Wrong input'
      puts result
    end
  end

  alias showsttr stations_and_trains # короткий псевдоним для stations_and_trains

  # stations_and_trains helper
  def showst
    puts 'Print station name from the list below'
    show_stations
    puts '...'
    name_enter = gets.chomp
    name_entered = Station.all_stations.find { |st| st.name == name_enter }
    puts '...'
    puts name_entered.trains_list
  end

  private

  # создавать станции
  def create_station
    loop do
      puts "===== Create station menu ===== \n"
      puts "Please enter station name in 'Abc' format, or 0 -> to return to main menu \n"
      station_name_input = gets.chomp
      break if station_name_input == '0'

      check_and_create(station_name_input)
      puts "Total stations created: #{Station.all_stations.size}"
      # вместо мемоизации решил использовать отдельный метод show_stations, где использовать мемоизацию - не придумал
      show_stations
    end
  end

  # 'create_station' helper
  def check_and_create(station)
    # тут начинается блок для перехвата исключений
    #  здесь может возникнуть исключение, поэтому ниже перхватываем его
    #  с помощью rescue. По факту новая станция не создастся,
    #  если ее имя не соответствует требованиям указанным
    #  в методе validate! (station.rb -> метод initialize)
    # begin
    Station.new(station)
    # перехватить исключение (оно может возникнуть из метода validate! при создании объекта,
    #  если пользователь вводит неверный аргумент, имя станции пустое или оно не соответствует
    #  требованиям к длине и тд.) и вывести сообщение об ошибке, без завершения программы.
    #  Сообщеие об ошибке записывается в переменную e.
    #  Само сообщение - берется в зависимости от ошибки, из списка ошибок метода validate!
  rescue RuntimeError => e
    puts "#{e.message}  Please Try again!" # выводит сообщение об ошибке
    # тут заканчивается блок для перехвата исключений
    # end
  end
end

# module contains main methods related to trains actions
module MainTrainsActions
  private

  # создавать поезда
  def create_trains
    loop do
      puts "=== Create train menu === \n1 -> cargo train | 2 -> passenger train | 0 -> back to menu"
      train_input = gets.chomp # .to_i
      break if train_input == '0'

      if train_input == '1'
        create_cargo
      else
        train_input == '2' ? create_passenger : (puts 'Wrong input!')
      end
    end
  end

  # create_trains helper1
  def create_cargo
    puts "Enter train number in '123-12' or 'abc-ab' format, or 0 -> to return to main menu \n"
    tr_num = gets.chomp
    # что тут происходит разжевано в методе create_station
    begin
      # (@nums += 1) раньше у меня тут автоматически создавались номера поездов, теперь их
      #  вводит пользователь и формат введенного номера проверяется на соответстви
      #  шаблону из константы TR_NUMBER train.rb
      CargoTrain.new(tr_num) # (@nums += 1)
    rescue RuntimeError => e
      puts "#{e.message} Please Try again!"
    end
    puts "Total trains created: #{Train.all_trains.size}"
    @show_trains.call
  end

  # create_trains helper2
  def create_passenger
    puts "Please enter train number in '123-12' or 'abc-ab' format, or 0 -> to return to menu \n"
    tr_num = gets.chomp
    begin
      PassengerTrain.new(tr_num) # (@nums += 1)
    rescue RuntimeError => e
      puts "#{e.message} Please Try again!"
    end
    puts "Total trains created: #{Train.all_trains.size}"
    @show_trains.call
  end

  # Перемещать поезд по маршруту вперед и назад
  #  В этом методе функционал ветвления вынесен в хелпер1
  #  Кажется это более правильный вариант чем в методах create_edit_route или create_trains
  #  где пришлось использвать nested ternary operator
  def move_train_back_forward
    loop do
      puts "=== Move train forwards-backwards according to route === \n"
      @select_tr_text.call
      select_train = gets.chomp
      break if select_train == '0'

      selected_train = Train.all_trains.find { |tr| tr.number == select_train }
      puts 'Press 1 to move forwards || Press 2 to move backwards'
      selected_move = gets.chomp.to_i
      move_train_case(selected_move, selected_train)
    end
  end
  # псевдоним для длинного имени метода, чтобы использовать короткое move вместо длинного move_train_back_forward
  # (# см. ИДИОМА 9 Alias. -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
  alias move move_train_back_forward

  # move_train_back_forward - helper1
  def move_train_case(move, train)
    case move
    when 1
      train.next_station
      puts "Train #{train.number} arrived to station: #{train.current_station}"
    when 2
      train.prev_station
      puts "Train #{train.number} arrived to station: #{train.current_station}"
    else
      puts 'Wrong input!'
    end
  end

  # Метод для вывода детальной информации по всем вагонам в поезде
  #  метод для каждого поезда на станции выводит список вагонов в формате:
  #  номер вагона, тип вагона, кол-во свободных и занятых мест (для пассажирского вагона)
  #  или кол-во свободного и занятого объема (для грузовых вагонов).
  def show_train_details
    loop do
      puts "=== Train wagons in details === \n"
      @select_tr_text.call
      select_train = gets.chomp
      break if select_train == '0'

      selected_train7 = Train.all_trains.find { |tr| tr.number == select_train }
      train_details(selected_train7)
    end
  end

  alias traind show_train_details

  # show_train_details mehod helper
  def train_details(train)
    train.train_details do |wagon| # передаем (не именованный) блок напрямую в метод train_details
      case wagon.type # блок универсальный и выдает информацию по вагону в зависимости от его типа
      when :passenger
        puts "--> Wagon number:#{wagon.number}; type:#{wagon.type};" \
        " occupied_seats:#{wagon.show_occupied_seats}; free_seats:#{wagon.show_free_seats}"
      when :cargo
        puts "--> Wagon number:#{wagon.number}; type:#{wagon.type};" \
        " occupied_volume:#{wagon.show_occupied_volume}; free_volume:#{wagon.show_free_volume}"
      end
    end
  end
end

# module contains secondary methods related to trains actions
module RestTrainsActions
  def find_train
    loop do
      @select_tr_text.call
      selected_train = gets.chomp
      break if selected_train == '0'

      puts "Search results: #{Train.all_trains.find { |tr| tr.number == selected_train }}"
    end
  end

  # метод устанавливает или возвращает производителя поезда, используется модуль Manufacturer
  def show_set_train_manuf
    loop do
      puts "=== Show or set train manufacturer === \n"
      @select_tr_text.call
      select_train = gets.chomp
      break if select_train == '0'

      selected_train = Train.all_trains.find { |tr| tr.number == select_train }
      puts 'Press 1 show manufacturer || Press 2 set manufacturer'
      selected_action = gets.chomp.to_i
      case_manuf(selected_action, selected_train)
    end
  end

  alias manuf show_set_train_manuf # короткий псевдоним для метода show_set_train_manuf

  # show_set_train_manuf helper1
  def case_manuf(action, train)
    case action
    when 1
      puts "Train #{train.number} manufacturer is: #{train.see_manufacturer}"
    when 2
      put_manuf(train)
    else
      puts 'Wrong input!'
    end
  end

  # show_set_train_manuf helper2
  def put_manuf(train)
    puts "Please enter manufacturer name\n..."
    manuf_name = gets.chomp.to_s
    train.put_manufacturer(manuf_name)
    puts "Train #{train.number} manufacturer is set to: #{train.see_manufacturer}"
  end
end

# module contains all methods related to wagons actions
module WagonsActions
  # Добавлять вагоны к поезду
  def add_wagon_to_train
    loop do
      puts "===== Add wagons to train menu ===== \n"
      @select_tr_text.call
      select_train = gets.chomp
      break if select_train == '0'

      selected_train = Train.all_trains.find { |tr| tr.number == select_train }
      add_wagon(selected_train) # вызываем отдельный метод и передаем ему selected_train1 в качестве параметра
    end
  end

  alias addw add_wagon_to_train

  # 'add_wagon_to_train' helper
  def add_wagon(train)
    wagon_type = train.options[:type]
    new_wagon = wagon_type == :cargo ? CargoWagon.new(@wagon_nums += 1) : PassengerWagon.new(@wagon_nums += 1)
    train.add_wagon(new_wagon)
    puts "Train #{train.number} got following wagons:"
    train.options[:wagons].each { |wag| puts "# #{wag.number}" }
  end

  # Отцеплять вагоны от поезда
  def detach_wagon_from_train
    loop do
      puts "===== Detach wagons from train menu ===== \n"
      # proc @select_tr_text содержит 3 строчки которые повторяются в 6 методах
      @select_tr_text.call
      select_train = gets.chomp
      break if select_train == '0'

      selected_train = Train.all_trains.find { |tr| tr.number == select_train }
      puts 'Choose wagon number to delete:'
      selected_train.options[:wagons].each { |wag| puts "# #{wag.number}" }
      detach_wagon(selected_train)
    end
  end

  alias detachw detach_wagon_from_train

  # 'detach_wagon_from_train' helper
  def detach_wagon(train)
    select_wagon = gets.chomp.to_i
    puts '...'
    selected_wagon = train.options[:wagons].find { |wag| wag.number == select_wagon }
    train.delete_wagon(selected_wagon)
    puts "Train #{train.number} got following wagons left:"
    train.options[:wagons].each { |wag| puts "# #{wag.number}" }
  end

  # метод для занятия места в вагоне (если вагон пассажирский - занимает место, если товарный - занимает объем )
  def occupy_space
    loop do
      @select_tr_text.call
      # TODO: здесь нужно будет перехватывать ошибку неверного ввода как в методе create_station
      select_train = gets.chomp
      break if select_train == '0'

      finding_train(select_train)
    end
  end

  # 'occupy_space' method helper1
  def finding_train(train)
    selected_train = Train.all_trains.detect { |tr| tr.number.eql?(train) }
    puts "Selected train is #{selected_train.options[:type]} type and contains following wagons: "
    # такая запись map(&:number) эквивалентна записи в следующей строке, но быстрее
    #  (см. ИДИОМА 7 Proc. -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
    puts selected_train.options[:wagons].map(&:number)
    # selected_train.wagons.each { |wag| puts wag.number }
    selecting_wagon(selected_train)
  end

  # 'occupy_space' method helper2
  def selecting_wagon(train)
    puts 'Enter wagon number'
    select_wagon2 = gets.chomp.to_i
    selected_wagon2 = train.options[:wagons].find { |wag| wag.number == select_wagon2 }
    selected_wagon2.type == :cargo ? occupy_cargo(selected_wagon2) : occupy_passenger(selected_wagon2)
  end

  # 'occupy_space' method helper3
  def occupy_cargo(wagon)
    puts "Please put volume in digits to be occupied in wagon ##{wagon.number}"
    volume = gets.chomp.to_i
    # выбрасываем исключение из метода occupy_volume, если объем введенного места
    #  превышает количество свободного места в вагоне. разжевано в методе create_station
    begin
      wagon.occupy_volume(volume)
    rescue RuntimeError => e
      puts "#{e.message} Please try again!"
    end
    # показать занятый объем вагона в соотношении с общим объемом в тоннах
    puts "- occupied volume: #{wagon.show_occupied_volume} tons out of #{wagon.max_volume}"
  end

  # 'occupy_space' method helper4
  def occupy_passenger(wagon)
    begin
      # тут, в отличии от грузового вагона у нас по умолчанию сразу занимается одно место
      wagon.occupy_seat
    rescue RuntimeError => e
      puts "#{e.message} Please try occupy seat in another wagon."
    end
    # показать количество занятых мест в соотношении с общим кол-вом мест
    puts "- occupied seats: #{wagon.show_occupied_seats} out of #{wagon.max_seats}"
  end
end

# module contains all methods related to routes actions
module RouteActions
  # выводит список всех маршрутов - номер маршрута и сам маршрут (используется в меню 3)
  def show_all_routes
    Route.routes.each do |num, route|
      print "#{num}: "
      route.stations.each { |rt| print "#{rt} " }
      puts "\n"
    end
  end

  # создавать маршруты и управлять станциями в нем (добавлять, удалять)
  def create_edit_route
    loop do
      puts "===== Create routes menu ===== \n"
      puts '1 -> create route | 2 -> edit route | 0 -> back to main menu'
      input = gets.chomp
      break if input == '0'

      result = create_route_menu if input == '1'
      result = add_or_del_from_route if input == '2'
      puts 'Wrong input!' unless result
    end
  end

  alias routece create_edit_route

  # create_edit_route helper 1
  def create_route_menu
    puts 'Choose and type first station name from list below'
    show_stations
    puts '...'
    st1 = gets.chomp
    puts 'Choose last station name from list below'
    show_stations
    st2 = gets.chomp
    create_route(st1, st2)
  end

  # create_edit_route helper 2
  def create_route(st1, st2)
    # блок обработки исключения при неверном/пустом/не существующем
    #  или не соответствующем шаблону вводе имени начальной или конечной станции
    begin
      # тут подставлям ввод, а не настоящие станции
      Route.new(st1, st2)
    rescue RuntimeError => e
      puts "#{e.message} Please try again!"
    end
    puts "Total routes created: #{Route.instances} \n"
    show_all_routes
  end

  # Назначать маршрут поезду
  def set_route
    loop do
      puts "===== Set route to train menu ===== \n"
      @select_tr_text.call
      select_train = gets.chomp
      break if select_train == '0'

      selected_train = Train.all_trains.find { |tr| tr.number == select_train }
      puts 'Select route number from the list below:'
      show_all_routes
      select_r(selected_train)
    end
  end

  # set_route helper
  def select_r(train)
    select_route = gets.chomp.to_i
    selected_route = Route.routes.fetch(select_route)
    # поезд принимает маршрут, вместе с этим поезд попадает
    #  в массив поездов первой станции в маршруте - это реализовано в методе accept_route train.rb
    train.accept_route(selected_route)
    puts "Train #{train.number} arrived to station: #{train.current_station}"
  end

  # метод удаляет или добавляет станцию к маршруту в зависимости от ввода. (используется в меню 3.2)
  #  этот метод максимально сокращен, в нем либо много строк,
  #  либо приходится использовать вложенный тернарник,
  #  он ужасен, но экономит строки
  def add_or_del_from_route
    puts 'Choose route to edit'
    show_all_routes
    puts 'Enter route number'
    route_select = gets.chomp.to_i
    chosen_route = Route.routes.fetch(route_select)
    # выводим содержимое выбранного маршрута
    puts "Chosen route is: #{chosen_route.stations}"
    adding_or_deleting(chosen_route)
  end

  # 'add_or_del_from_route' method helper1
  def adding_or_deleting(route)
    # предлагаем добавить или убрать станцию из маршрута
    #  (убрать можно только одну за раз, если их больше двух в маршруте)
    puts '1 -> add station || 2 -> delete station'
    add_or_del = gets.chomp # .to_i
    # If add_or_del equals 1, call 'add_st' with 'chosen_route' as argument
    #  If not, check if equals 2, if so, call 'del_st' with 'chosen_route' as argument
    #  If none of conditions met, puts 'Wrong input'.
    if add_or_del == '1'
      add_st(route)
    else
      add_or_del == '2' ? del_st(route) : (puts 'Wrong input')
    end
  end

  # 'add_or_del_from_route' method helper2
  def add_st(route)
    puts 'Choose and type station to add from list below'
    show_stations
    puts '...'
    station_to_add_input = gets.chomp
    station_to_add = Station.all_stations.find { |st| st.name == station_to_add_input }
    route.add_station(station_to_add.name) # добавляем станцию к маршруту
    puts route.stations
  end

  # 'add_or_del_from_route' method helper3
  def del_st(route)
    puts 'Choose and type station to delete from list below'
    puts route.stations
    puts '...'
    station_to_del_input = gets.chomp
    station_to_del = route.stations.find { |st| st == station_to_del_input }
    route.delete_station(station_to_del) # удаляем станцию из маршрута
    puts route.stations
  end
end

# User text interface class
class Interface
  include StationsActions
  include MainTrainsActions
  include RestTrainsActions
  include WagonsActions
  include RouteActions

  def initialize
    # @nums - старый аттрибут, когда не было проверок ввода пользователя
    #  (пользователь вообще не вводил номер поезда) и номера поездов создавались автоматически
    # @nums = 0
    @wagon_nums = 0 # счетчик для создания вагонов - меню пункт 5
    # class instance variable to store data in lambda (pr proc)
    #  returns text in menu methods
    @show_trains = -> { Train.all_trains.map { |obj| puts "Train # #{obj.number} #{obj.options[:type]}" } }
    # class instance variable to store data in lambda (pr proc)
    #  returns text in menu methods
    @select_tr_text = lambda do
      puts 'Select train number from the list below or enter 0 -> back to main menu'
      # TODO: правильнее заменить на fetch https://github.com/rubocop/ruby-style-guide#hash-fetch
      Train.all_trains.map { |obj| puts "Train # #{obj.number} #{obj.options[:type]}" }
      puts '...'
    end

    # тестовые данные, раскомментируйте для проверок
    # Station.new('tas')
    # Station.new('chi')
    # Station.new('yan')
    # Station.new('pit')
    # Train.new('123-ab') # (@nums += 1)
    # CargoTrain.new('abc-12') # (@nums += 1)
    # PassengerTrain.new('567-78') # (@nums += 1)
    # t5 = PassengerTrain.new('new-34')
    # t7 = PassengerTrain.new('new-37')
    # t8 = CargoTrain.new('new-38')

    # Route.new(Station.all_stations[0].name, Station.all_stations[1].name)
    # Train.all_trains[1].accept_route(Route.routes[1]) # поезд "abc-12" принимает маршрут №1
    # Train.all_trains[2].accept_route(Route.routes[1]) # поезд "567-78" принимает маршрут №1
    # Train.all_trains[1].add_wagon(CargoWagon.new(@wagon_nums += 1)) # поезду "abc-12" добавляется вагон
    # Train.all_trains[2].add_wagon(PassengerWagon.new(@wagon_nums += 1)) # поезду "567-78" добавляется вагон
    # # это синглтон метод для единственного объекта класса Train # для проверки идиомы № 14
    # #  (# см. ИДИОМА 14 "singleton method". -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
    # unique_train = Train.all_trains[0]
    # def unique_train.set_unique_manuf
    #   options[:manufacturer] = 'UNIQUE'
    # end

    # unique_train.set_unique_manuf
    # puts unique_train.options[:manufacturer]

    # проверка protected метода register_instance
    # tr10 = CargoTrain.new(@nums += 1)   # 1. проверка что метод register_instance в самом деле protected
    # tr10.register_instance              # 2
    # @mem_stations ||= @stations.map{ |obj| obj.name }
  end

  # меню
  def call
    loop do
      menu_text
      answers
      input = gets.chomp
      break if input == '0'

      # /1[0-5]|[1-9]/ в диапозоне от 10 до 15 или 1 до 9. Потому что нелья просто указать диапазон вида [1-15]
      #  примеры: https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch06s07.html
      result = input =~ /1[0-5]|[1-9]/ ? answers[input].call : 'wrong input!'
      puts result
    end
  end

  # 'call' helper1
  def menu_text
    puts "Choose action: \n0 -> quit\n1 -> create station\n2 -> create train\n"\
    "3 -> create or edit route\n4 -> set route to train\n5 -> add wagons to train\n"\
    "6 -> remove wagons from train\n7 -> move train according to route\n"\
    "8 -> list of stations with trains\n9 -> show or set train manufacturer\n"\
    "10 -> show all station class instances\n11 -> find train by number\n12 -> Show instances\n"\
    "13 -> Occupy space in wagon\n14 -> Show all stations details\n15 -> Show train details"
  end

  # 'call' helper2
  def answers
    # заменил case на hash (согласно ИДИОМЕ 8 -> CodeAcademy\Idioms_and_Good_Style\idioms.rb) тут есть нюанс,
    #  т.к в значениях у меня методы - то вызываются они через method. https://stackoverflow.com/questions/27645773/store-functions-in-hash
    #  также заменил длинные имена методов на пседвонимы
    #  (# см. ИДИОМА 9 Alias. -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
    # create_station - создавать станции,  # create_trains - создавать поезда
    { '1' => method(:create_station), '2' => method(:create_trains),
      # routece - cоздавать маршруты и управлять станциями в нем (добавлять, удалять),
      #  set_route - назначать маршрут поезду
      '3' => method(:routece), '4' => method(:set_route),
      # addw - добавлять вагоны к поезду, # detachw - отцеплять вагоны от поезда
      '5' => method(:addw), '6' => method(:detachw),
      # move - Перемещать поезд по маршруту вперед и назад,
      #  showsttr - Просматривать список станций и список поездов на станции
      '7' => method(:move), '8' => method(:showsttr),
      '9' => method(:manuf), '10' => method(:show_stations),
      '11' => method(:find_train), '12' => method(:showin),
      '13' => method(:occupy_space), '14' => method(:stationd),
      '15' => method(:traind) }
  end

  # выводит экземпляры всех классов
  def show_all_instances
    puts "Station instances: #{Station.instances}"
    puts "Route instances: #{Route.instances}"
    puts "Train instances: #{Train.instances}"
    puts "Cargo train instances: #{CargoTrain.instances}"
    puts "Passenger train instances: #{PassengerTrain.instances}"
  end

  alias showin show_all_instances
end
