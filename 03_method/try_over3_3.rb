module TryOver3
  # Q1
  # 以下要件を満たすクラス TryOver3::A1 を作成してください。
  # - run_test というインスタンスメソッドを持ち、それはnilを返す
  # - `test_` から始まるインスタンスメソッドが実行された場合、このクラスは `run_test` メソッドを実行する
  # - `test_` メソッドがこのクラスに実装されていなくても `test_` から始まるメッセージに応答することができる
  # - TryOver3::A1 には `test_` から始まるインスタンスメソッドが定義されていない
  class A1
    TEST_METHOD_PREFIX = 'test_'

    def run_test
      nil
    end

    def method_missing(method_name, **args)
      return super unless method_name.start_with?(TEST_METHOD_PREFIX)
      run_test
    end

    def respond_to_missing?(method_name, include_private = false)
      return super unless method_name.start_with?(TEST_METHOD_PREFIX)
      true
    end
  end

  # Q2
  # 以下要件を満たす TryOver3::A2Proxy クラスを作成してください。
  # - TryOver3::A2Proxy は initialize に TryOver3::A2 のインスタンスを受け取り、それを @source に代入する
  # - TryOver3::A2Proxy は、@sourceに定義されているメソッドが自分自身に定義されているように振る舞う
  class A2
    def initialize(name, value)
      instance_variable_set("@#{name}", value)
      self.class.attr_accessor name.to_sym unless respond_to? name.to_sym
    end
  end

  class A2Proxy
    def initialize(source)
      @source = source
    end

    def method_missing(name, *args)
      args.any? ? @source.public_send(name, args[0]) : @source.public_send(name)
    end

    def respond_to_missing?(name, include_private = false)
      @source.respond_to?(name)
    end
  end

  # Q3
  # 前回 OriginalAccessor の my_attr_accessor で定義した getter/setter に boolean の値が入っている場合には #{name}? が定義されるようなモジュールを実装しました。
  # 今回は、そのモジュールに boolean 以外が入っている場合には hoge? メソッドが存在しないようにする変更を加えてください。
  # （以下は god の模範解答を一部変更したものです。以下のコードに変更を加えてください）
  module OriginalAccessor2
    def self.included(mod)
      mod.define_singleton_method :my_attr_accessor do |attr_sym|
        define_method attr_sym do
          @attr
        end

        define_method "#{attr_sym}=" do |value|
          if [true, false].include?(value) && !respond_to?("#{attr_sym}?")
            self.class.define_method "#{attr_sym}?" do
              @attr == true
            end
          end
          if respond_to?("#{attr_sym}?") && [true, false].none?(value)
            self.class.remove_method("#{attr_sym}?")
          end
          @attr = value
        end
      end
    end
  end


  # Q4
  # 以下のように実行できる TryOver3::A4 クラスを作成してください。
  # TryOver3::A4.runners = [:Hoge]
  # TryOver3::A4::Hoge.run
  # # => "run Hoge"

  class A4
    class << self
      def runners
        @const_array
      end

      def runners= const_array
        @const_array = const_array
      end

      def const_missing(name)
        super unless @const_array.include?(name)

        klass_instance = Class.new do |klass|
          klass.define_singleton_method :run do
            "run #{name}"
          end
        end

        klass_instance
      end
    end
  end

  # Q5. チャレンジ問題！ 挑戦する方はテストの skip を外して挑戦してみてください。
  #
  # TryOver3::TaskHelper という include すると task というクラスマクロが与えられる以下のようなモジュールがあります。
  module TaskHelper
    def self.included(klass)
      klass.define_singleton_method :task do |name, &task_block|
        new_klass = Class.new do
          define_singleton_method :run do
            puts "start #{Time.now}"
            block_return = task_block.call
            puts "finish #{Time.now}"
            block_return
          end
        end
        new_klass_name = name.to_s.split("_").map{ |w| w[0] = w[0].upcase; w }.join
        const_set(new_klass_name, new_klass)
      end
    end
  end

  # TryOver3::TaskHelper は include することで以下のような使い方ができます
  class A5Task
    include TaskHelper

    task :foo do
      "foo"
    end
  end
  # irb(main):001:0> A3Task::Foo.run
  # start 2020-01-07 18:03:10 +0900
  # finish 2020-01-07 18:03:10 +0900
  # => "foo"

  # 今回 TryOver3::TaskHelper では TryOver3::A5Task::Foo のように Foo クラスを作らず TryOver3::A5Task.foo のようにクラスメソッドとして task で定義された名前のクラスメソッドでブロックを実行するように変更したいです。
  # 現在 TryOver3::TaskHelper のユーザには TryOver3::A5Task::Foo.run のように生成されたクラスを使って実行しているユーザが存在します。
  # 今回変更を加えても、その人たちにはこれまで通り生成されたクラスのrunメソッドでタスクを実行できるようにしておいて、warning だけだしておくようにしたいです。
  # TryOver3::TaskHelper を修正してそれを実現してください。 なお、その際、クラスは実行されない限り生成されないものとします。
  #
  # 変更後想定する使い方
  # メソッドを使ったケース
  # irb(main):001:0> TryOver3::A5Task.foo
  # start 2020-01-07 18:03:10 +0900
  # finish 2020-01-07 18:03:10 +0900
  # => "foo"
  #
  # クラスのrunメソッドを使ったケース
  # irb(main):001:0> TryOver3::A5Task::Foo.run
  # Warning: TryOver3::A5Task::Foo.run is deprecated
  # start 2020-01-07 18:03:10 +0900
  # finish 2020-01-07 18:03:10 +0900
  # => "foo"
end
