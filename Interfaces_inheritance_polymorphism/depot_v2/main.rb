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

require_relative 'interface'

Interface.new.call

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
