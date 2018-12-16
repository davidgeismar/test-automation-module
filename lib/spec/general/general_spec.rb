module SpecUtils
  module General
    class InstanceMethod < Spec
      attr_accessor :method
      before :generate, call: [:write_indent]

      def initialize(file, klass, indent, method)
        super(file, klass, indent)
        self.method = method
      end

      def generate
        file.write("it { is_expected.to respond_to :#{method} }\n")
      end
    end

    class Kind < Spec
      attr_accessor :kind
      before :generate,  call: [:write_indent]
      def initialize(file, klass, indent=nil, kind)
        super(file, klass, indent)
        self.kind = kind
      end

      def generate
        if klass.included_modules.include?(kind)
          file.write("it { is_expected.to be_kind_of #{kind} }\n")
        end
      end
    end

    class Exemple
      include Indentation
      include Hooks
      attr_accessor :file, :description, :indent
      before :generate,  call: [:write_indent]

      def initialize(file, klass, description, indent=nil)
        self.file = file
        self.klass = klass
        self.description = description
        self.indent = indent
      end

      def generate
        if block_given?
          file.write("it '#{description}' do\n")
          yield
          write_end
        else
          file.write("it '#{description}'\n")
        end
      end
    end

    class Expect
      include Indentation
      include Hooks
      attr_accessor :file, :actual, :expected, :comparator, :indent
      before :generate,  call: [:write_indent]
      def initialize(file, klass, actual, expected, comparator, indent=nil)
        self.file = file
        self.klass = klass
        self.actual = actual
        self.expected = expected
        self.comparator = comparator
        self.indent = indent
      end

      def generate
        file.write("expect#{actual}.#{comparator} #{expected} \n")
      end
    end
  end
end
