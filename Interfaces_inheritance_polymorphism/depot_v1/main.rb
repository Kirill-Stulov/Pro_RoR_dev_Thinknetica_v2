# Добавить текстовый интерфейс:
# Создать программу в файле main.rb, которая будет позволять пользователю через текстовый интерфейс делать следующее:
# 	Создавать станции
# 	Создавать поезда
# 	Создавать маршруты и управлять станциями в нем (добавлять, удалять)
# 	Назначать маршрут поезду
# 	Добавлять вагоны к поезду
# 	Отцеплять вагоны от поезда
# 	Перемещать поезд по маршруту вперед и назад
# 	Просматривать список станций и список поездов на станции
# В качестве ответа приложить ссылку на репозиторий с решением

require_relative 'station'
require_relative 'train'
require_relative 'wagon'
require_relative 'route'

class Depot
  @@stations = []   # хранить станции для меню
  @@trains = []     # хранить поезда для меню
  @@wagons = []     # хранить вагоны для меню
  @@routes = {}     # хранить маршруты для меню
  @routes_count = 0 # счетчик для маршрутов
  @nums = 0         # счетик для создания поездов - меню пунтк 2
  @wagon_nums = 0   # счетик для создания вагонов - меню пунтк 5

  # тестовые данные, разкомментируйте для проверок
  # @@stations << Station.new("tas")
  # @@stations << Station.new("chi")
  # @@stations << Station.new("yan")
  # @@stations << Station.new("pit")
  # @@trains << CargoTrain.new(@nums += 1)
  # @@trains << PassengerTrain.new(@nums += 1)
  # @@routes[@routes_count += 1] = Route.new(@@stations[0], @@stations[1])
  # @@trains[0].accept_route(@@routes[1]) # поезд принимает маршрут №1 

  # выводит список всех маршрутов - номер мершрута и сам маршрут
  def self.show_all_routes
    @@routes.each do |num, route|                   
    print num.to_s + ": " 
    route.all_stations_names#.to_s
    end
  end

  # метод удаляет или добавляет станцию к маршруту в зависимости от ввода. (используется в меню 3.2)
  def self.add_or_delete_from_route
    puts "Choose route to edit"
    show_all_routes
    puts "Enter route number"
    route_select = gets.chomp.to_i
    chosen_route = @@routes.fetch(route_select)
    puts "Chosen route is: #{chosen_route.stations}"                      # выводим содержимое выбранного маршрута
    puts "1 -> add station"                                               # предлагаем добавить или убрать станцию из маршрута (убрать можно только одну за раз, если их больше двух в маршруте)
    puts "2 -> delete station"
    add_or_delete = gets.chomp.to_i
    if add_or_delete == 1
      puts "Choose and type station to add from list below"
      @@stations.map{ |obj| puts obj.name }
      puts "..."
      station_to_add_input = gets.chomp
      station_to_add = @@stations.find { |st| st.name == station_to_add_input }
      chosen_route.add_station(station_to_add) # добавляем станцию к маршруту
      puts chosen_route.all_stations_names
    elsif add_or_delete == 2
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
    break if input == 0
    while input == 1                               # Создавать станции
      puts "===== Create station menu ===== \n"
      puts "Please enter station name, or 0 -> to return to main menu \n"
      station_name_input = gets.chomp.strip.to_s                          # strip отсекает пробелы
      break if station_name_input == '0'
        if station_name_input.empty?
          puts "Name can not be blank!"
        elsif @@stations.any? { |obj| obj.name == station_name_input }
          puts "Station #{station_name_input} is already exists! \n"
        else
          @@stations << Station.new(station_name_input.to_s) 
          puts "Total stations created: #{@@stations.length}"
          @@stations.map{ |obj| puts obj.name }
        end
    end
    while input == 2                            # создавать поезда 
      puts "===== Create train menu ===== \n"
      puts "1 -> create cargo train"
      puts "2 -> create passenger train" 
      puts "0 -> back to main menu"
      train_input = gets.chomp.to_i
      if train_input == 1
        @@trains << CargoTrain.new(@nums += 1)
        puts "Total trains created: #{@@trains.length}"
        @@trains.map{ |obj| puts "Train # #{obj.number}" }
      elsif train_input == 2
        @@trains << PassengerTrain.new(@nums += 1)
        puts "Total trains created: #{@@trains.length}"
        @@trains.map{ |obj| puts "Train # #{obj.number}" }
      elsif train_input == 0
        break
      else 
        puts "Wrong input!"
      end
    end
    while input == 3                          # Создавать маршруты и управлять станциями в нем (добавлять, удалять)
      puts "===== Create routes menu ===== \n"
      puts "1 -> create route"
      puts "2 -> edit route" 
      puts "0 -> back to main menu"
      route_input = gets.chomp.to_i
      if route_input == 1
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
      elsif route_input == 2
        add_or_delete_from_route          
      elsif route_input == 0
        break
      else 
        puts "Wrong input!"
      end
    end
    while input == 4                                    # Назначать маршрут поезду
      puts "===== Set route to train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" }
      puts "..."
      select_train = gets.chomp.to_i
      break if select_train == 0
      selected_train = @@trains.find { |tr| tr.number == select_train }
      puts "Select route number from the list below:"
      show_all_routes
      select_route = gets.chomp.to_i
      selected_route = @@routes.fetch(select_route)
      selected_train.accept_route(selected_route)   # поезд принимает маршрут
      selected_train.current_station.accept_train(selected_train) # станция принимает поезд
      puts "Train #{selected_train.number} arrived to station: #{selected_train.current_station.name}" 
    end
    while input == 5                                    # Добавлять вагоны к поезду
      puts "===== Add wagons to train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train1 = gets.chomp.to_i
      break if select_train1 == 0
      selected_train1 = @@trains.find { |tr| tr.number == select_train1 }
      if selected_train1.type == :cargo
        selected_train1.add_wagon( CargoWagon.new(@wagon_nums += 1) )
      elsif selected_train1.type == :passenger
        selected_train1.add_wagon( PassengerWagon.new(@wagon_nums += 1) )
      end
      puts "Train #{selected_train1.number} got following wagons:"
      selected_train1.wagons.each{ |wag| puts "# "+ wag.number.to_s }
    end
    while input == 6                                    # Отцеплять вагоны от поезда
      puts "===== Detach wagons from train menu ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train2 = gets.chomp.to_i
      break if select_train2 == 0
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
    while input == 7                                    # Перемещать поезд по маршруту вперед и назад
      puts "===== Move train forwards-backwards accoring to route ===== \n"
      puts "Select train number from the list below or enter 0 -> back to main menu"
      @@trains.map{ |obj| puts "Train # #{obj.number}" + " #{obj.type}" }
      puts "..."
      select_train3 = gets.chomp.to_i
      break if select_train3 == 0
      selected_train3 = @@trains.find { |tr| tr.number == select_train3 }
      puts "Press 1 to move forwards || Press 2 to move backwards"
      selected_move = gets.chomp.to_i
      if selected_move == 1
        selected_train3.next_station
        puts "Train #{selected_train3.number} arrived to station: #{selected_train3.current_station.name}"
      elsif selected_move == 2
        selected_train3.prev_station
        puts "Train #{selected_train3.number} arrived to station: #{selected_train3.current_station.name}"
      else 
        puts "Wrong input!"
      end
    end
    while input == 8                                  # Просматривать список станций и список поездов на станции
      puts "===== Show list of stations and trains menu ===== \n"
      puts "Print station name from the list below or enter 0 -> back to main menu"
      @@stations.map{ |obj| puts obj.name }
      puts "..."
      name_enter = gets.chomp
      break if name_enter == 0
      name_entered = @@stations.find { |st| st.name == name_enter }
      if name_entered.trains.empty?
        puts "This station got no trains yet!"
      else
        name_entered.trains.each { |tr| puts tr.number.to_s + tr.type.to_s }
      end
    end
  end

end

# station1 = Station.new("Tash")
# station2 = Station.new("Piter")
# station3 = Station.new("Vasyuki")
# station4 = Station.new("Belgrad")

# route1 = Route.new(station1, station2)
# route2 = Route.new(station3, station4)

# train1 = CargoTrain.new(1)
# train2 = PassengerTrain.new(2)
# train3 = CargoTrain.new(3)
# train4 = CargoTrain.new(4)

# wagon1 = CargoWagon.new(1)
# wagon2 = CargoWagon.new(2)
# wagon3 = PassengerWagon.new(3)
# wagon4 = PassengerWagon.new(4)

# station1.accept_train(train1)
# station1.accept_train(train2)
# station1.accept_train(train3)
# station1.send_train(train2)

# train1.accept_route(route1)
# p train1.current_station.name
# p train1.show_next_station.name
# train1.next_station
# puts "route:"
# # p route1.stations
# route1.add_station(station3)
# route1.stations.each{|st| p "-" + st.name}
# puts "edited route:"
# route1.delete_station(station1)
# route1.stations.each{|st| p "-" + st.name}
