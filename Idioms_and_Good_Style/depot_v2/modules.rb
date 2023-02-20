# frozen_string_literal: true

# collection of modules
# InstanceCounter contains class and instance methods
# 1. Создать модуль, который позволит указывать название компании-производителя и получать его.
#  Подключить модуль к классам Вагон и Поезд
# 2. Создать модуль InstanceCounter, содержащий следующие методы класса и инстанс-методы,
#  которые подключаются автоматически при вызове include в классе:
# • Методы класса:
#    - instances, который возвращает кол-во экземпляров данного класса
# • Инстанс-методы:
#  - register_instance, который увеличивает счетчик кол-ва экземпляров класса
#  и который можно вызвать из конструктора. При этом данный метод не должен быть публичным.
# • Подключить этот модуль в классы поезда, маршрута и станции.
# Примечание: инстансы подклассов могут считаться по отдельности,
#  не увеличивая счетчик инстансов базового класса (для этого мне нужно использовать инстанс переменные класса).
#  для совмещения методов класса и инстанс методов (занятие 5 00:32) добавляем
#  еще два модуля - ClassMethods и InstanceMethod

# модуль позволяет указывать название компании-производителя и получать его.
#  Подключен к классам Вагон и Поезд
module Manufacturer
  def put_manufacturer(manufacturer)
    options[:manufacturer] = manufacturer
  end

  def see_manufacturer
    options[:manufacturer]
  end
end

# модуль InstanceCounter описан в пункте 2
module InstanceCounter
  # это нужно чтобы в классе, в котором подключаем этот модуль
  #   было достаточно написать include InstanceCounter, вместо "extend InstanceCounter::ClassMethods"
  #   и "include InstanceCounter::InstanceMethods" (занятие 5 00:38)
  def self.included(base)
    # так подключаются методы класса
    base.extend ClassMethods
    # так инстанс методы
    base.send :include, InstanceMethods
  end

  # модуль содержащий методы класса
  module ClassMethods
    # создаем и подключаем переменную класса instances, которая будет хранить кол-во экземпляров класса
    attr_accessor :instances, :stations, :routes, :trains

    # метод класса - возвращает кол-во экземпляров данного класса
    # !!! МЕТОД БЫЛ ПЕРЕИМЕНОВАН ИЗ instances в all_instances !!!
    # ЭТОТ МЕТОД ВООБЩЕ НУЖЕН?!
    def all_instances
      @all_instances
    end

    # !!! МЕТОД НУЖНО ПЕРЕИМЕНОВАТЬ!
    def all_trains
      @all_trains ||= []
    end

    # метод класса - возвращает кол-во экземпляров данного класса
    #  (возвращает все созданные станции класса Station).
    #  Этот дополнительный метод класса понадобился для (валидации) в методах validate! классов Station и Route
    # !!! МЕТОД БЫЛ ПЕРЕИМЕНОВАН ИЗ stations в all_stations !!!
    def all_stations
      @all_stations ||= []
    end

    # метод класса - возвращает кол-во экземпляров данного класса
    #  (возвращает все созданные маршруты).
    # !!! МЕТОД БЫЛ ПЕРЕИМЕНОВАН ИЗ routes в all_routes !!!
    def all_routes
      # тут нужно было присвоить пустому хешу заранее, иначе при первом вызове -
      #  не будет срабатывать метод Route.routes.any? из метода existing_route? в route.rb,
      #  т.к хеша для проверки просто не будет существовать при самом первом создании объекта
      @all_routes ||= {}
    end
  end

  # модуль содержащий методы инстанса
  module InstanceMethods
    # метод подключается в конструкторе класса Station и кладет каждый созданный экземпляр в массив
    def stations_collect
      self.class.all_stations ||= []
      self.class.all_stations << self
    end

    # метод для сохранения всех поездов в одном месте - массиве trains класса Train
    def trains_collect
      # 3. а этот вариант то что нужно.
      #  Указываем что сохраняем не в массив trains класса к которому принадлежит объект,
      #  а в массив trains родительского класса
      # self.class.superclass.trains ||= []
      # self.class.superclass.trains << self

      # 2. этот вариант не очень подходит, потому что имя класса прописано фактически
      Train.all_trains ||= []
      Train.all_trains << self

      # 1. в этом случае экземпляры класса будут записываться в массив trains того класса, которому они принадлежат,
      # а мне нужно чтобы поезда всех типов сохранялись в один массив общего родительского класса Train
      # self.class.trains ||= []
      # self.class.trains << self
    end

    # метод для сохранения всех маршрутов в одном месте - массиве routes класса Route
    def routes_collect
      self.class.routes ||= {}
      # TODO: проверить метод route/existing_route? !!!!!
      # self.class.routes << self # stations # теперь @routes это не массив, а хеш
      # Route.instances - текущий порядковый номер маршрута - ключ, а объект маршрута - значение.
      #  Каждый раз при создании маршрута, новая пара будет записываться в хеш @routes
      self.class.routes[Route.instances] = self
    end

    # доступ к инстанс методам должен быть ограничен,
    #  но при этом в наследовании метод должен работать,
    #  потому protected (на самом деле, private тожк будет работать)
    protected

    # instance метод - увеличивает счетчик кол-ва экземпляров класса, можно вызвать из конструктора
    def register_instance
      # Без этой строки не будет условия для правильного начального
      #  и последующего значения счетчика. Если просто присвоить первоначально 0,
      #  то при добавлении новых экземпляров (поезд, вагон), счетик не будет увеличиваться.
      #  ||= 0 означает, что если переменной instances уже что-то присвоено,
      #  то ничего не присваиваем, оставляя текущее значение(по сути присваиваем текущее значение).
      #  Если ничего не присвоено (т.е там nil), присваиваем 0.
      #  Если непонятно, смотри файл RoR_from_zero\CodeAcademy\Operators\or_equal.rb (или idioms.rb)
      self.class.instances ||= 0
      # !!! для того чтобы вызвать из инстанс метода (register_instance) метод класса (instances)
      #  нужно писать self затем class затем метод класса
      self.class.instances += 1
    end
  end
end

# это нужно для переопределения дефолтного метода map по заданию №8
#  (# см. ИДИОМА 13 "Расширение и дополнение классов" (40:55) -> CodeAcademy\Idioms_and_Good_Style\idioms.rb)
class Array
  def map
    return to_enum(:map) unless block_given?

    ary = []
    each { |x| ary << yield(x) }
    # этот метод от стандартного метода map отличается только тем,
    # что возвращает массив в алфавитном порядке с помощью sort
    ary.sort
  end
end
