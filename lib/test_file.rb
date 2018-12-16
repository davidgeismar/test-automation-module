class TestFile
  attr_accessor :klass, :file, :strategy

  def initialize(file, klass, strategy)
    self.klass = klass
    self.file = file
    self.strategy = strategy
  end

  def generate
    strategy.each do |hash|
      hash[:klass].new(file, klass, *hash[:args], 0).generate() do
        recursive_call(hash, 0)
      end
    end
  end

  # trasverse recursively the configuration hash while instancing classes
  def recursive_call(call, padding)
    if call[:block]
      padding += 1
      call[:block].each do |subcall|
        subcall[:klass].new(file, klass, *subcall[:args], padding).generate() do
          recursive_call(subcall, padding)
        end
      end
    else
      call[:klass].new(file, klass, *call[:args], padding).generate()
    end
  end
end
