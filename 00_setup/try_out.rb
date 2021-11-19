class TryOut
  class TryOut
    attr_accessor :first_name
    attr_reader :middle_name, :last_name
  
    def initialize(first_name, *middle_name, last_name)
      # 引数の制御ってどこでやるのがベストなんだろ？
      raise ArgumentError if middle_name.size > 1 || !first_name || !last_name
  
      @first_name = first_name
      @middle_name = middle_name if middle_name.any?
      @last_name = last_name
    end
  
    def full_name
      self.upcased_full_name || [first_name, middle_name, last_name].compact.join(' ')
    end
  
    def upcase_full_name
      full_name.upcase
    end
  
    def upcase_full_name!
      self.upcased_full_name = full_name.upcase!
    end
  
    private
  
    attr_accessor :upcased_full_name
  end
end
