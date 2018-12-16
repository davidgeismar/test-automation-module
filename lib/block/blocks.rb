module BlockUtils
  class Context < Block
    attr_accessor :context_name, :file, :indent, :klass
    before :generate, call: [:write_indent]
    after :generate, call: [:write_end]

    def initialize(file, klass, context_name, indent=nil)
      super(file, klass, indent)
      self.context_name = context_name
    end

    def generate
      file.write("context '#{context_name}' do\n")
      super
    end
  end

  class RSpec < Block
    attr_accessor :spec_nature, :klass
    after :generate, call: [:write_end]

    def initialize(file, klass, spec_nature, indent=nil)
      super(file, klass, indent)
      self.spec_nature = spec_nature
    end

    def generate
      file.write("RSpec.describe #{klass}, type: :#{spec_nature} do\n")
      super
    end
  end

  class Before < Block
    attr_accessor :scope
    before :generate, call: [:write_indent]
    after :generate, call: [:write_end]

    def initialize(file, klass, scope=nil, indent=nil)
      super(file, klass, indent)
      self.scope = scope
    end
    def generate
      if scope
        file.write("before(#{scope}) do\n")
      else
        file.write("before do\n")
      end
      super
    end
  end

  class Describe < Block
    attr_accessor :description
    before :generate, call: [:write_indent]
    after :generate, call: [:write_end]

    def initialize(file, klass, description, indent=nil)
      super(file, klass, indent)
      self.description = description
    end

    def generate
      file.write("describe '#{description}' do \n")
      super
    end
  end
end
