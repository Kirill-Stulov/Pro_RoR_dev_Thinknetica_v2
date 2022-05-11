require_relative 'station'
require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'
require_relative 'wagon'
require_relative 'cargo_wagon'
require_relative 'passenger_wagon'
require_relative 'route'

class Interface
  @@stations = []   # хранить станции для меню
  @@trains = []     # хранить поезда для меню
  @@wagons = []     # хранить вагоны для меню
  @@routes = {}     # хранить маршруты для меню
  @routes_count = 0
  @nums = 0         # счетик для создания поездов - меню пунтк 2
  @wagon_nums = 0   # счетик для создания вагонов - меню пунтк 5

  # тестовые данные, разкомментируйте для проверок
  @@stations << Station.new("tas") 
  @@stations << Station.new("chi")
  @@stations << Station.new("yan")
  @@stations << Station.new("pit")
  @@trains << CargoTrain.new(@nums += 1)
  @@trains << PassengerTrain.new(@nums += 1)
  @@routes[@routes_count += 1] = Route.new(@@stations[0], @@stations[1]) # 
  @@trains[0].accept_route(@@routes[1]) # поезд принимает маршрут №1 

  def self.create_station                       # создавать станции
    loop do
      puts "===== Create station menu ===== \n"
      puts "Please enter station name, or 0 -> to return to main menu \n"
      station_name_input = gets.chomp.strip.to_s                          # strip отсекает пробелы
      case station_name_input
      when '0'                                 #  в случае когда когда код после while вынесен в метод, break не действует, потому используем return
        break
      else
        @@stations << Station.new(station_name_input.to_s) 
        puts "Total stations created: #{@@stations.length}"
        @@stations.map{ |obj| puts obj.name }
      end
    end
  end

  def self.create_trains                        # создавать поезда
    loop do
      puts "===== Create train menu ===== \n"
      puts "1 -> create cargo train"
      puts "2 -> create passenger train" 
      puts "0 -> back to main menu"
      train_input = gets.chomp.to_i
      case train_input
      when 1
        @@trains << CargoTrain.new(@nums += 1)
        puts "Total trains created: #{@@trains.length}"
        @@trains.map{ |obj| puts "Train # #{obj.number}" }
      when 2
        @@trains << PassengerTrain.new(@nums += 1)
        puts "Total trains created: #{@@trains.length}"
        @@trains.map{ |obj| puts "Train # #{obj.number}" }
      when 0
        break
      else 
          puts "Wrong input!"
      end
    end
  end

  def self.create_edit_route                    # создавать маршруты и управлять станциями в нем (добавлять, удалять)
    loop do
      puts "===== Create routes menu ===== \n"
      puts "1 -> create route"
      puts "2 -> edit route" 
      puts "0 -> back to main menu"
      route_input = gets.chomp.to_i
      case route_input
      when 1
        puts "Choose and type first station name from list below"
        @@stations.map{ |obj| puts obj.name }
        puts "..."
        first_station_input = gets.chomp
        puts "Choose last station name from list below"
        @@stations.map{ |obj| puts obj.name }
        puts "..."
        last_station_input = gets.chomp
        first_station = @@stations.find { |st| st.name == first_station_input }
        last_station = @@stations.find { |st| st.name == last_station_input }
        @@routes[@routes_count += 1] = Route.new(first_station, last_station)
        puts "Total routes created: #{@@routes.length} \n"
        show_all_routes
      when 2
        add_or_delete_from_route          
      when 0
        break
      else 
        puts "Wrong input!"
      end
    end
  end

  def self.set_route                            # Назначать маршрут поезду
    loop do                                                                      
      puts "===== Set route to train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" }
      puts "..."
      select_train = gets.chomp.to_i
      case select_train
      when 0
        break
      else
        selected_train = @@trains.find { |tr| tr.number == select_train }
        puts "Select route number from the list below:"
        show_all_routes
        select_route = gets.chomp.to_i
        selected_route = @@routes.fetch(select_route)
        selected_train.accept_route(selected_route)   # поезд принимает маршрут
        selected_train.current_station.accept_train(selected_train) # станция принимает поезд
        puts "Train #{selected_train.number} arrived to station: #{selected_train.current_station.name}"
    end
    end 
  end

  def self.add_wagon_to_train                   # Добавлять вагоны к поезду
    loop do                                  
      puts "===== Add wagons to train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train1 = gets.chomp.to_i
      case select_train1
      when 0
        break
      else
        selected_train1 = @@trains.find { |tr| tr.number == select_train1 }
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

  def self.detach_wagon_from_train              # Отцеплять вагоны от поезда
    loop do                                  
      puts "===== Detach wagons from train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train2 = gets.chomp.to_i
      case select_train2
      when 0
        break
      else
        selected_train2 = @@trains.find { |tr| tr.number == select_train2 }
        puts "Choose wagon number to delete:"
        selected_train2.wagons.each{ |wag| puts "# "+ wag.number.to_s }
        select_wagon = gets.chomp.to_i
        puts "..."
        selected_wagon = selected_train2.wagons.find { |wag| wag.number == select_wagon }
        selected_train2.delete_wagon(selected_wagon)
        puts "Train #{selected_train2.number} got following wagons left:"
        selected_train2.wagons.each{ |wag| puts "# "+ wag.number.to_s }
      end
    end
  end

  def self.move_train_back_forward              # Перемещать поезд по маршруту вперед и назад
    loop do                                   
      puts "===== Move train forwards-backwards accoring to route ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train3 = gets.chomp.to_i
      case select_train3
      when 0
        break
      else
        selected_train3 = @@trains.find { |tr| tr.number == select_train3 }
        puts "Press 1 to move forwards || Press 2 to move backwards"
        selected_move = gets.chomp.to_i
        case selected_move
        when 1
          selected_train3.next_station
          puts "Train #{selected_train3.number} arrived to station: #{selected_train3.current_station.name}"
        when 2
          selected_train3.prev_station
          puts "Train #{selected_train3.number} arrived to station: #{selected_train3.current_station.name}"
        else 
          puts "Wrong input!"
        end
      end
    end
  end

  # выводит список всех маршрутов - номер мершрута и сам маршрут
  def self.show_all_routes
    @@routes.each do |num, route|                   
    print num.to_s + ": " 
    route.all_stations_names
    puts "\n"
    end
  end

  # метод удаляет или добавляет станцию к маршруту в зависимости от ввода. (используется в меню 3.2)
  def self.add_or_delete_from_route
    puts "Choose route to edit"
    show_all_routes
    puts "Enter route number"
    route_select = gets.chomp.to_i
    chosen_route = @@routes.fetch(route_select)
    puts "Chosen route is: #{chosen_route.stations}"                             # выводим содержимое выбранного маршрута
    puts "1 -> add station"                                               # предлагаем добавить или убрать станцию из маршрута (убрать можно только одну за раз, если их больше двух в маршруте)
    puts "2 -> delete station"
    add_or_delete = gets.chomp.to_i
    case add_or_delete
    when 1
      puts "Choose and type station to add from list below"
      @@stations.map{ |obj| puts obj.name }
      puts "..."
      station_to_add_input = gets.chomp
      station_to_add = @@stations.find { |st| st.name == station_to_add_input }
      chosen_route.add_station(station_to_add) # добавляем станцию к маршруту
      puts chosen_route.all_stations_names
    when 2
      puts "Choose and type station to delete from list below"
      puts chosen_route.all_stations_names
      puts "..."
      station_to_del_input = gets.chomp
      station_to_del = chosen_route.stations.find { |st| st.name == station_to_del_input }
      chosen_route.delete_station(station_to_del) # удаляем станцию из маршрута
      puts chosen_route.all_stations_names
    else
      puts "Wrong input"
    end
  end

  def self.show_stations_and_trains             # Просматривать список станций и список поездов на станции
    loop do                              
      puts "===== Show list of stations and trains menu ===== \n"
      puts "1 -> Show list of stations"
      puts "0 -> back to main menu"
      enter = gets.chomp.to_i
      case enter
      when 1
        puts "Print station name from the list below"
        @@stations.map{ |obj| puts obj.name }
        puts "..."
        name_enter = gets.chomp
        name_entered = @@stations.find { |st| st.name == name_enter }
        # name_entered.trains.each { |tr| puts tr.number.to_s + tr.type.to_s }
        puts "..."
        puts name_entered.show_trains_by_type("cargo")
        puts name_entered.show_trains_by_type("passenger")
      when 0
        break
      else
        puts "Wrong input"
      end
    end
  end

  # меню
  loop do
    puts "Choose action: \n"
    puts "0 -> quit"
    puts "1 -> create station"
    puts "2 -> create train"
    puts "3 -> create or edit route"
    puts "4 -> set route to train"
    puts "5 -> add wagons to train"
    puts "6 -> remove wagons from train"
    puts "7 -> move train forwards-backwards accoring to route"
    puts "8 -> show list of stations and trains on it"
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
    end
  end

end
