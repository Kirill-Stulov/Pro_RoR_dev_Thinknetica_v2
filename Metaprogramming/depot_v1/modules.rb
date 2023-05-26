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
# Из задания №9
#  3. модуль Acсessors, содержащий динамические методы, которые можно вызывать на уровне класса:
#   - attr_accessor_with_history, динамически создает геттеры и сеттеры для любого кол-ва атрибутов
#   - <имя_атрибута>_history, возвращает массив всех значений данной переменной.
#   - strong_attr_accessor, принимает имя атрибута и его класс. При этом создается геттер и сеттер
#     для одноименной инстанс-  переменной, но сеттер проверяет тип присваемоего значения.
#     Если тип присваемоего значения отличается от того, который указан вторым параметром, то выбрасывается исключение.
#     Если тип совпадает, то значение присваивается.
#  4. модуль Validation, который:
#     Содержит метод класса validate.
#     Содержит инстанс-метод validate!, который запускает все проверки (валидации), указанные в классе через
#     метод класса validate.
#     В случае ошибки валидации выбрасывает исключение с сообщением о том, какая именно валидация не прошла
#     Содержит инстанс-метод valid? который возвращает true, если все проверки валидации прошли успешно и false,
#     если есть ошибки валидации.

# Module containing all validations
module Validation
  def self.included(base)
    # так подключаются методы класса
    base.extend ClassMethods
    # так инстанс методы
    base.send :include, InstanceMethods
  end

  # module containing validation Class methods
  module ClassMethods
    # заменил метод validate2 на хеш содержащий Validations и укороченный метод validate2 ниже
    # кладем все валидации в хеш, внутри каждая валидация хранится в лямбде
    # VALIDATIONS  is a hash constant that contains a collection of validation rules.
    # values of the hash are lambda functions that implement the corresponding validation rule
    #  where 'value' is always the value that needs to be validated
    #  arg is optional and used for some types of validations, such as :format or :type
    #  raises an exception if the validation fails.
    VALIDATIONS = {
      presence: ->(value, _arg) { raise 'Enter can not be empty or nil!' if value.nil? || value.empty? },
      format: ->(value, arg) { raise 'Wrong format entered!' if value !~ arg },
      type: ->(value, arg) { raise 'Type is wrong!' if value.class != arg },
      existing_train: ->(value, _arg) { raise 'Train number alredy exist!' if Train.existing_train?(value) },
      # проверка что не создается уже существующая станция
      existing_station: ->(value, _arg) { raise "'#{value}' already exist!" if Station.existing_station?(value) },
      # используется для проверки что в маршрут не пытаемся добавить несуществующую станцию
      # non_exist_station: ->(value, _arg) { raise 'Station not exist!' unless Station.existing_station?(value) },
      non_exist_station: ->(value, _arg) { raise "'#{value}' not exist!" unless Station.existing_station?(value) },
      # используется для проверки cтанций при создании маршрута
      existing_fs: ->(value, _arg) { raise 'Non existing 1st station entered!' unless Route.existing_fs?(value) },
      existing_ls: ->(value, _arg) { raise 'Non existing last station entered!' unless Route.existing_ls?(value) },
      existing_route: ->(value, _arg) { raise 'This route is alredy exists!' if Route.existing_route?(value) }
    }.freeze

    # 'object' refers to the object that will be validated
    # 'string' нужен для метода validate_st_name, который принимает строку
    # 'attr_name' refers to name of attribute within object that will be validated
    # 'arg' optional parameter that can be used to pass in additional arguments
    #   for certain types of validations (e.g. a regular expression for format validation)
    def validate2(object_or_string, attr_name, validation_type, arg = nil)
      # using object argument (it is actually self from (self, :name, :presence) )
      #  to call 'send' method on it, passing attr_name argument
      #  this is getting the value of the instance variable with the name attr_name (in this case :name)
      #  using the getter method of the class
      # value = object.send(attr_name) # старый вариант учитывавший только строку
      # если переданный параметр строка, приваиваем ее в value, если объект, то сначала достаем значение
      # имени объекта (которое строка)
      # if validate2 called on object during intialization - we use object_or_string.send(attr_name),
      #  if it was called on string value - then we use value of 'object_or_string'
      #  variable (this case used to validate user enter in add_st(route) method)
      value = object_or_string.is_a?(String) ? object_or_string : object_or_string.send(attr_name)
      # validation_type as the key to retrieve the lambda function from the hash
      #  and call it with 'value' and 'arg' as arguments
      VALIDATIONS[validation_type].call(value, arg)
    end

    # метод класса, созданный для валидации в add_st(route) и del_st(route),
    #  этот отдельный метод нужен, т.к ему передается на проверку строка, а не объект
    #   потому нельзя использовать метод validate2!, т.к он вызывается на объекте
    #   экземпляра класса в который примешан модуль Validate
    def validate_st_name(st_name)
      # метод validate2 умеет вызывать соответствующую проверку из хеша VALIDATIONS и по строке и по объекту,
      #  но метод validate_st_name нужен только для строки
      validate2(st_name, :name, :presence)
      validate2(st_name, :name, :non_exist_station)
    rescue RuntimeError => e
      puts e.message
    end
  end

  # инстанс методы
  module InstanceMethods
    # VALIDATIONS2 hash definition wrapped inside a lambda function
    VALIDATIONS2 = lambda {
      {
        Station => [%i[name presence], %i[name format], %i[name existing_station]],
        Route => [%i[first_station existing_fs], %i[last_station existing_ls], %i[stations existing_route]],
        PassengerTrain => [%i[number presence], %i[number format], %i[number existing_train]],
        CargoTrain => [%i[number presence], %i[number format], %i[number existing_train]]
      }
    }

    protected

    # инстанс-метод validate2!, запускает все проверки (валидации), указанные в классе
    #  через метод класса validate. Вместо 'case' сделан через метод метапрограммирования 'send'
    def validate2!(format = nil)
      # тут передаем format в параметре, потому что его шаблон arg может быть разным,
      #  в зависимости от того на каком классе метод validate2! вызван и какой тип проверки идет в методе
      #  т.е когда метод проверяет не format а presence, arg не передается и по умолчанию игнорируется - arg = nil
      #  прим. в случае проверки объекта класса Station на format, arg у format будет STNAME_FORMAT
      validations = VALIDATIONS2.call # call invokes lambda function and returns hash that it wraps.
      # (self.class) - это Station или Route в зависимости от того на чем был вызван validate2!
      raise "Validation not implemented for #{self.class} class" unless validations.key?(self.class) # это if

      validations[self.class].each do |validation| # это else
        validation << format if validation[1] == :format
        # self.class  represents the class of that object
        #  send method calls validate2 method dynamically based on class of current object.
        #  self represents instance of object that is currently being validated
        self.class.send(:validate2, self, *validation)
      end
    end

    # инстанс-метод valid? который возвращает true, если все проверки валидации прошли успешно
    #  и false, если есть ошибки валидации.
    def valid2?(format, arg = nil)
      validate2!(format, arg)
      puts true
    rescue RuntimeError
      puts false
    end
  end
end

# vodule for accessors methods
module Accessors
  # метод динамически создает геттеры и сеттеры для любого кол-ва атрибутов, (Занятие 09 Метапрограммирование 31:54)
  #  при этом сеттер сохраняет все значения инстанс-переменной при изменении этого значения.
  #  пример стр 52 RoR_from_zero\CodeAcademy\OOP-1\Metaprogramming\metaprogramming.rb
  #  подключается во всех классах
  def attr_accessor_with_history(*attrs)
    attrs.each do |name|
      # Convert the attribute name to instance variable symbol and prepend it with '@'
      attr_name = "@#{name}".to_sym
      # Append '_history' to the attribute name and convert it to a symbol
      history_name = "@#{name}_history".to_sym

      # Define a getter method for the attribute that returns its current value
      define_method(name) { instance_variable_get(attr_name) } # !геттер

      # Define a setter method for attribute that sets its value and updates its history
      define_method("#{name}=".to_sym) do |value| # !сеттер
        # Set the value of the attribute to the new value
        instance_variable_set(attr_name, value)
        # Get the current history of the attribute or initialize it to an empty array if it doesn't exist yet
        history = instance_variable_get(history_name) || []
        # Add the new value to the history array
        history << value
        # Set the updated history array using instance_variable_set
        instance_variable_set(history_name, history)
      end

      # Define a getter method for the attribute's history that returns
      #  its current history or an empty array if it doesn't exist yet
      define_method("#{name}_history".to_sym) { instance_variable_get(history_name) || [] } # геттер по истории
    end
  end

  # метод динамически принимает имя атрибута и его класс
  #  При этом создается геттер и сеттер для одноименной инстанс переменной,
  #  но сеттер проверяет тип присваемоего значения. Если тип отличается от того,
  #  который указан вторым параметром, то выбрасывается исключение.
  #  Если тип совпадает, то значение присваивается.
  def strong_attr_accessor(name, type)
    attr_name = "@#{name}".to_sym
    define_method(name) { instance_variable_get(attr_name) } # getter

    # аксессор присваивает значение если условие выполняется,
    #  если не выполняется - выбрасывает исключение о несоответствии типа присваемого значения
    #  типу значения, которое было передано вторым параметром
    define_method("#{name}=".to_sym) do |value|
      raise "Only #{type} data type allowed for @#{name} instance!" if value.class != type

      # else
      instance_variable_set(attr_name, value)
    end
  end
end

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

# модуль InstanceCounter описан в пункте 2. Класс в который подключается этот модуль
#  фактически расширяется методами этого модуля
module InstanceCounter
  # это нужно чтобы в классе, в котором подключаем этот модуль
  #   было достаточно написать include InstanceCounter, вместо "extend InstanceCounter::ClassMethods"
  #   и "include InstanceCounter::InstanceMethods" (занятие 5 00:38 и занятие 9 6:00)
  def self.included(base)
    # так подключаются методы класса
    base.extend ClassMethods
    # так инстанс методы
    base.send :include, InstanceMethods
  end

  # модуль содержащий методы класса
  module ClassMethods
    # создаем и подключаем переменную класса all_instances, которая будет хранить кол-во экземпляров класса
    attr_accessor :all_instances

    # метод класса - возвращает кол-во экземпляров данного класса
    # def all_instances
    #   @all_instances
    # end

    def all_trains
      @all_trains ||= []
    end

    # метод класса - возвращает кол-во экземпляров данного класса
    #  (возвращает все созданные станции класса Station).
    #  Этот дополнительный метод класса понадобился для (валидации) в методах validate! классов Station и Route
    def all_stations
      @all_stations ||= []
    end

    # метод класса - возвращает кол-во экземпляров данного класса
    #  (возвращает все созданные маршруты).
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
      # self.class.superclass.all_trains ||= []
      # self.class.superclass.all_trains << self

      # 2. этот вариант не очень подходит, потому что имя класса прописано фактически
      Train.all_trains ||= []
      Train.all_trains << self

      # 1. в этом случае экземпляры класса будут записываться в массив trains того класса, которому они принадлежат,
      # а мне нужно чтобы поезда всех типов сохранялись в один массив общего родительского класса Train
      # self.class.all_trains ||= []
      # self.class.all_trains << self
    end

    # метод для сохранения всех маршрутов в одном месте - массиве routes класса Route
    def routes_collect
      self.class.all_routes ||= {}
      # Route.all_instances - текущий порядковый номер маршрута - ключ, а объект маршрута - значение.
      #  Каждый раз при создании маршрута, новая пара будет записываться в хеш @all_routes
      self.class.all_routes[Route.all_instances] = self
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
      self.class.all_instances ||= 0
      # !!! для того чтобы вызвать из инстанс метода (register_instance) метод класса (instances)
      #  нужно писать self затем class затем метод класса
      self.class.all_instances += 1
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
