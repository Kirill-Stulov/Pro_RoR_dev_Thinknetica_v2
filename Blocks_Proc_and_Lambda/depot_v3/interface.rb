require_relative 'modules'
require_relative 'station'
require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'
require_relative 'route'

class Interface

  def initialize
    @stations = []   # хранить станции для меню                         # в этом файле в дальнейшем, вместо локальной @stations нужно использвать инстанс переменную уровня класса @stations из модуля InstanceCounter, чтобы было DRY
    @trains = []     # хранить поезда для меню
    @wagons = []     # хранить вагоны для меню
    @routes = {}     # хранить маршруты для меню
    @routes_count = 0
    @nums = 0         # счетик для создания поездов - меню пунтк 2
    @wagon_nums = 0   # счетик для создания вагонов - меню пунтк 5
    
    # тестовые данные, раскомментируйте для проверок
    @stations << Station.new("tas") 
    @stations << Station.new("chi")
    @stations << Station.new("yan")
    @stations << Station.new("pit")
    @trains << Train.new("123-ab")                                          #(@nums += 1) старые аттрибуты, когда не было проверок вода пользователя (пользователь вообще не вводил номер поезда) и номера поездов сохдавались автоматически
    @trains << CargoTrain.new("abc-12")                                     #(@nums += 1)
    @trains << PassengerTrain.new("567-78")                                 #(@nums += 1)
    @routes[@routes_count += 1] = Route.new(@stations[0].name, @stations[1].name)
    @trains[1].accept_route(@routes[1]) # поезд "abc-12" принимает маршрут №1 
    @trains[2].accept_route(@routes[1]) # поезд "567-78" принимает маршрут №1
    @trains[1].add_wagon( CargoWagon.new(@wagon_nums += 1) )      # поезду "abc-12" добавляется вагон
    @trains[2].add_wagon( PassengerWagon.new(@wagon_nums += 1) )  # поезду "567-78" добавляется вагон
    # проверка protected метода register_instance
    # tr10 = CargoTrain.new(@nums += 1)   # 1. проверка что метод register_instance в самом деле protected
    # tr10.register_instance              # 2
  end

  # выводит список всех маршрутов - номер мершрута и сам маршрут
  def show_all_routes
    @routes.each do |num, route|                   
      print num.to_s + ": " 
      route.stations.each { |rt| print rt + " " } #all_stations_names
      puts "\n"
    end
  end

  # меню
  def call  
    loop do
      puts "Choose action: \n"
      puts "0 -> quit"
      puts "1 -> create station"
      puts "2 -> create train"
      puts "3 -> create or edit route"
      puts "4 -> set route to train"
      puts "5 -> add wagons to train"
      puts "6 -> remove wagons from train"
      puts "7 -> move train forwards-backwards according to route"
      puts "8 -> show list of stations and trains on it"
      puts "9 -> show or set train manufacturer"
      puts "10 -> show all station class instances"
      puts "11 -> find train by number"                                 #!!!!!!!! исправить этот метод, теперь номера поездов другие!
      puts "12 -> Show instances"
      puts "13 -> Occupy space in vagon"
      puts "14 -> Show all stations details"
      puts "15 -> Show train details"
      input = gets.chomp.to_i
      case input
      when 0
        break
      when 1                            # создавать станции
        create_station
      when 2                            # создавать поезда 
        create_trains
      when 3                            # создавать маршруты и управлять станциями в нем (добавлять, удалять)
        create_edit_route
      when 4                            # Назначать маршрут поезду
        set_route
      when 5                            # Добавлять вагоны к поезду
        add_wagon_to_train
      when 6                            # Отцеплять вагоны от поезда
        detach_wagon_from_train
      when 7                            # Перемещать поезд по маршруту вперед и назад
        move_train_back_forward
      when 8                            # Просматривать список станций и список поездов на станции
        show_stations_and_trains
      when 9
        show_set_train_manuf
      when 10
        # puts Station.all                # выводит все экземпляры класса Station через метод класса all из Station
        puts Station.stations #(new)    # это работает благодаря инстанс методу stations_collect из модуля InstanceCounter
        # puts Route.show_stations_in_station_class  # (new) получил доступ к данным класса Station из класса Route!!!
      when 11
        find_train
      when 12
        puts "Station instances: #{ Station.instances } "
        puts "Route instances: #{ Route.instances } "
        puts "Train instances: #{ Train.instances } "  
        puts "Cargo train instances: #{ CargoTrain.instances } "           # выводит количество экземпляров класса Train, метод класса из модуля InstaceCounter
        puts "Passenger train instances: #{ PassengerTrain.instances } "
      # end
      when 13
        occupy_space                                                       # меню для занятия места в вагоне (если пассажирский - занимает место, если товарный - занимает объем )
      when 14
        show_station_details                                               # выводит подробный список станций и поездов на этих станциях, внутри метод station_details - который принимает блок и проходит по всем станциям и поездам на этих станциях, передавая каждый поезд в блок. 17:00 - 19:00.
      when 15 
        show_train_details                                                 # выводит подробный список поездов их вагонов, внутри метод all_trains_details - который принимает блок и проходит по всем поездам и их вагонам, передавая каждый вагон в блок. 17:00 - 19:00
      end
    end
  end

  private # тут private, а не protected, потому что у интерфейса нет наследников

  def show_stations_and_trains             # Просматривать список станций и список поездов на станции
    loop do                              
      puts "===== Show list of stations and trains menu ===== \n"
      puts "1 -> Show list of stations"
      puts "0 -> back to main menu"
      enter = gets.chomp.to_i
      case enter
      when 1
        puts "Print station name from the list below"
        @stations.map{ |obj| puts obj.name }
        puts "..."
        name_enter = gets.chomp
        name_entered = Station.stations.find { |st| st.name == name_enter }
        # name_entered = @stations.find { |st| st.name == name_enter }
        # name_entered.trains.each { |tr| puts tr.number.to_s + tr.type.to_s }
        puts "..."
        puts name_entered.trains_list
      when 0
        break
      else
        puts "Wrong input"
      end
    end
  end

  def create_station                       # создавать станции
    loop do
      puts "===== Create station menu ===== \n"
      puts "Please enter station name in 'Abc' format, or 0 -> to return to main menu \n"
      station_name_input = gets.chomp#.strip.to_s                          # strip отсекает пробелы (это не нужно теперь, т.к появились проверки через регулярку в методе validate!)
      case station_name_input
      when '0'                                 #  в случае когда когда код после while вынесен в метод, break не действует, потому используем return
        break
      else
        begin                                                 # тут начинается блок для перехвата исключений
          @stations << Station.new(station_name_input)         # здесь может возникнуть исключение, поэтому ниже перхватываем его с помощью rescue. По факту новая станция не создастся, если ее имя не соответствует требованиям указанным в методе validate! (station.rb -> метод initialize)
        rescue RuntimeError => e                                # перехватить исключение (оно может возникнуть из метода validate! при создании объекта, если пользователь вводит неверный аргумент, имя станции пустое или оно не соответствует требованиям к длине и тд.) и вывести сообщение об ошибке, без завершения программы. Сообщеие об ошибке записывается в переменную e. Само сообщение - берется в зависимости от ошибки, из списка ошибок метода validate!
          puts " #{e.message}  Please Try again!"                  # выводит сообщение об ошибке
        end                                                         # тут заканчивается блок для перехвата исключений
          puts "Total stations created: #{@stations.length}"
          @stations.map{ |obj| puts obj.name }
      end
    end
  end

  def create_trains                        # создавать поезда
    loop do
      puts "===== Create train menu ===== \n"
      puts "1 -> create cargo train"
      puts "2 -> create passenger train" 
      puts "0 -> back to main menu"
      train_input = gets.chomp.to_i
      case train_input
      when 1
        puts "Please enter train number in '123-12' or 'abc-ab' format, or 0 -> to return to main menu \n"
        train_num_input = gets.chomp
        begin                                               # что тут происходит разжевано в методе create_station
          @trains << CargoTrain.new(train_num_input)                         #(@nums += 1) раньше у меня тут автоматически создавались номера поездов, теперь их вводит пользователь и формат введенного номера проверяется на соответстви шаблону из константы TR_NUMBER train.rb            
        rescue RuntimeError => e
          puts "#{e.message} Please Try again!"
        end
        puts "Total trains created: #{@trains.length}"
        @trains.map{ |obj| puts "Train # #{obj.number}" }
      when 2
        puts "Please enter train number in '123-12' or 'abc-ab' format, or 0 -> to return to main menu \n"
        train_num_input = gets.chomp
        begin
          @trains << PassengerTrain.new(train_num_input)                     #(@nums += 1)
        rescue RuntimeError => e
          puts "#{e.message} Please Try again!"
        # end
      end
        puts "Total trains created: #{@trains.length}"
        @trains.map{ |obj| puts "Train # #{obj.number}" }
      when 0
        break
      # else 
          # puts "Wrong input!"                               # От этого нужно будет избавиться, т.к появились проверки через регулярку в методе validate!)
      end
    end
  end

  def create_edit_route                    # создавать маршруты и управлять станциями в нем (добавлять, удалять)
    loop do
      puts "===== Create routes menu ===== \n"
      puts "1 -> create route"
      puts "2 -> edit route" 
      puts "0 -> back to main menu"
      route_input = gets.chomp.to_i
      case route_input
      when 1
        puts "Choose and type first station name from list below"
        @stations.map{ |obj| puts obj.name }                                    # тут в дальнейшем нужно использвать инстанс переменную уровня класса @stations из модуля InstanceCounter
        puts "..."
        first_station_input = gets.chomp
        puts "Choose last station name from list below"
        @stations.map{ |obj| puts obj.name }
        puts "..."
        last_station_input = gets.chomp
        # first_station = @stations.find { |st| st.name == first_station_input }   # решил использовать просто имена станций, а не объект, потому закоментированно. тут сделать проверку на валидность имени. ПРисваиваем только если имя существует. # Это нужно, чтобы по вводу пользователя найти в массиве уже существующий объект станции. Здесь  т.к появилась проверка валидности методом validate! в route.rb  
        # last_station = @stations.find { |st| st.name == last_station_input } 
        begin                                                                        # блок обработки исключения при неверном/пустом/не существующем/не соответствующем шаблону вводе имени начальной или конечной станции
          @routes[@routes_count += 1] = Route.new(first_station_input, last_station_input)   # тут подставлям ввод, а не настоящие станции
        rescue RuntimeError => e
          puts "#{e.message} Please try again!"
        end
        puts "Total routes created: #{@routes.length} \n"
        show_all_routes
      when 2
        add_or_delete_from_route          
      when 0
        break
      end
    end
  end

  def set_route                            # Назначать маршрут поезду
    loop do                                                                      
      puts "===== Set route to train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @trains.map{ |obj| puts "Train # #{obj.number}" }
      puts "..."
      select_train = gets.chomp#.to_i
      case select_train
      when '0'
        break
      else
        selected_train = @trains.find { |tr| tr.number == select_train }
        puts "Select route number from the list below:"
        show_all_routes
        select_route = gets.chomp.to_i
        selected_route = @routes.fetch(select_route)
        selected_train.accept_route(selected_route)   # поезд принимает маршрут, вместе с этим поезд попадает в массив поездов первой станции в маршруте - это реализовано в методе accept_route train.rb 
        puts "Train #{selected_train.number} arrived to station: #{selected_train.current_station}"
      end
    end 
  end

  def add_wagon_to_train                   # Добавлять вагоны к поезду
    loop do                                  
      puts "===== Add wagons to train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train1 = gets.chomp
      case select_train1
      when '0'
        break
      else
        selected_train1 = @trains.find { |tr| tr.number == select_train1 }
        case selected_train1.type
        when :cargo 
        selected_train1.add_wagon( CargoWagon.new(@wagon_nums += 1) )
        puts "Train #{selected_train1.number} got following wagons:"
        selected_train1.wagons.each{ |wag| puts "# "+ wag.number.to_s }
        when :passenger
        selected_train1.add_wagon( PassengerWagon.new(@wagon_nums += 1) )
        puts "Train #{selected_train1.number} got following wagons:"
        selected_train1.wagons.each{ |wag| puts "# "+ wag.number.to_s }
        end
      end
    end
  end

  def detach_wagon_from_train              # Отцеплять вагоны от поезда
    loop do                                  
      puts "===== Detach wagons from train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train2 = gets.chomp
      case select_train2
      when '0'
        break
      else
        selected_train2 = @trains.find { |tr| tr.number == select_train2 }
        puts "Choose wagon number to delete:"
        selected_train2.wagons.each { |wag| puts "# "+ wag.number.to_s }
        select_wagon = gets.chomp.to_i
        puts "..."
        selected_wagon = selected_train2.wagons.find { |wag| wag.number == select_wagon }
        selected_train2.delete_wagon(selected_wagon)
        puts "Train #{selected_train2.number} got following wagons left:"
        selected_train2.wagons.each{ |wag| puts "# "+ wag.number.to_s }
      end
    end
  end

  def move_train_back_forward              # Перемещать поезд по маршруту вперед и назад
    loop do                                   
      puts "===== Move train forwards-backwards accoring to route ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @trains.map { |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train3 = gets.chomp
      case select_train3
      when '0'
        break
      else
        selected_train3 = @trains.find { |tr| tr.number == select_train3 }
        puts "Press 1 to move forwards || Press 2 to move backwards"
        selected_move = gets.chomp.to_i
        case selected_move
        when 1
          selected_train3.next_station
          puts "Train #{selected_train3.number} arrived to station: #{selected_train3.current_station}"
        when 2
          selected_train3.prev_station
          puts "Train #{selected_train3.number} arrived to station: #{selected_train3.current_station}"
        else 
          puts "Wrong input!"
        end
      end
    end
  end

  # метод удаляет или добавляет станцию к маршруту в зависимости от ввода. (используется в меню 3.2)
  def add_or_delete_from_route
    puts "Choose route to edit"
    show_all_routes
    puts "Enter route number"
    route_select = gets.chomp.to_i
    chosen_route = @routes.fetch(route_select)
    puts "Chosen route is: #{chosen_route.stations}"                             # выводим содержимое выбранного маршрута
    puts "1 -> add station"                                               # предлагаем добавить или убрать станцию из маршрута (убрать можно только одну за раз, если их больше двух в маршруте)
    puts "2 -> delete station"
    add_or_delete = gets.chomp.to_i
    case add_or_delete
    when 1
      puts "Choose and type station to add from list below"
      @stations.map { |obj| puts obj.name }
      puts "..."
      station_to_add_input = gets.chomp
      station_to_add = @stations.find { |st| st.name == station_to_add_input }
      chosen_route.add_station(station_to_add.name)                             # добавляем станцию к маршруту
      puts chosen_route.stations
    when 2
      puts "Choose and type station to delete from list below"
      puts chosen_route.all_stations_names
      puts "..."
      station_to_del_input = gets.chomp
      station_to_del = chosen_route.stations.find { |st| st.name == station_to_del_input }
      chosen_route.delete_station(station_to_del.name)                          # удаляем станцию из маршрута
      puts chosen_route.all_stations_names
    else
      puts "Wrong input"
    end
  end

  # метод устанавливает или возвращает производителя поезда, используется модуль Manufacturer
  def show_set_train_manuf
    loop do                                   
      puts "===== Show or set train manufacturer ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @trains.map { |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train4 = gets.chomp
      case select_train4
      when '0'
        break
      else
        selected_train4 = @trains.find { |tr| tr.number == select_train4 }
        puts "Press 1 show manufacturer || Press 2 set manufacturer"
        selected_action = gets.chomp.to_i
        case selected_action
        when 1
          puts "Train #{selected_train4.number} manufacturer is: #{selected_train4.get_manufacturer}"
        when 2
          puts "Please enter manufacturer name"
          puts "..."
          manuf_name = gets.chomp.to_s
          selected_train4.set_manufacturer(manuf_name)
          puts "Train #{selected_train4.number} manufacturer is set to: #{selected_train4.get_manufacturer}"
        else 
          puts "Wrong input!"
        end
      end
    end
  end

  def find_train
    loop do  
      puts "Enter train number or enter 0 -> back to main menu"
      puts "..."
      selected_train5 = gets.chomp#.to_i
      case selected_train5
      when '0'
        break
      else
        puts Train.find(selected_train5)
      end
    end
  end

  # метод для занятия места в вагоне (если вагон пассажирский - занимает место, если товарный - занимает объем )
  def occupy_space
    loop do
      puts "Enter train number from list below or enter 0 -> back to main menu"
      @trains.each { |tr| puts "Number:#{tr.number} => type:#{tr.type}" }
      puts "..."
      select_train6 = gets.chomp                                                               # !!!!!здесь нужно будет перехватывать ошибку неверного ввода как в методе create_station
      case select_train6
      when '0'
        break
      else
        selected_train6 = @trains.find { |tr| tr.number == select_train6 }                                          
        puts "Selected train is #{selected_train6.type} type and contains following wagons: "
        selected_train6.wagons.each { |wag| puts wag.number }
        puts "Enter wagon number"
        select_wagon2 = gets.chomp.to_i
        selected_wagon2 = selected_train6.wagons.find { |wag| wag.number == select_wagon2 }
        case selected_wagon2.type
        when :cargo
          puts "Please put volume in digits to be occupied in wagon ##{selected_wagon2.number}"
          volume = gets.chomp.to_i
          begin                                           # выбрасываем исключение из метода occupy_volume, если объем введенног места превышает количество свободного места в вагоне. разжевано в методе create_station
            selected_wagon2.occupy_volume(volume)
          rescue RuntimeError => e
            puts "#{e.message} Please try again!"
          end
          puts "- occupied volume: #{selected_wagon2.show_occupied_volume} tons out of #{selected_wagon2.max_volume}" # показать занятый объем вагона в соотношении с общим объемом в тоннах
        when :passenger
          begin
            selected_wagon2.occupy_seat                                                         # тут, в отличии от грузового вагона у нас по умолчанию сразу занимается одно место
          rescue RuntimeError => e
            puts "#{e.message} Please try occupy seat in another wagon."
          end
          puts "- occupied seats: #{selected_wagon2.show_occupied_seats} out of #{selected_wagon2.max_seats}" # показать количество занятых мест в соотношении с общим кол-вом мест 
        end
      end
    end
  end

  # Метод для вывода детальной информации по всем станциям и поездам на них
  def show_station_details                    
    puts '===== All stations in details ====='
    Station.stations_details { |station|                                                                                    # передаем (не именованный) блок напрямую в метод station_details, хотя лучше выглядел первый вариант из depot, когда я передавал именованный блок через lambda
      puts station.name
      station.trains.each { |train| puts "-> Train ##{train.number}; Type:#{train.type}; Vagons:#{train.wagons.length}" }
     }
  end

  # Метод для вывода детальной информации по всем вагонам в поезде
   #  метод для каждого поезда на станции выводит список вагонов в формате:
    # номер вагона, тип вагона, кол-во свободных и занятых мест (для пассажирского вагона) или кол-во свободного и занятого объема (для грузовых вагонов).
  def show_train_details
    loop do                                  
      puts "===== Train wagons in details ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train7 = gets.chomp
      case select_train7
      when '0'
        break
      else
        selected_train7 = @trains.find { |tr| tr.number == select_train7 }
        selected_train7.train_details { |wagon|                               # передаем (не именованный) блок напрямую в метод train_details
          case wagon.type                                                       # блок универсальный и выдает информацию по вагону в зависимости от его типа
          when :passenger                          
            puts "--> Wagon number:#{wagon.number}; type:#{wagon.type}; occupied_seats:#{wagon.show_occupied_seats}; free_seats:#{wagon.show_free_seats} "
          when :cargo
            puts "--> Wagon number:#{wagon.number}; type:#{wagon.type}; occupied_volume:#{wagon.show_occupied_volume}; free_volume:#{wagon.show_free_volume} "                      
          end
         }                             
      end
    end
  end
    
end
