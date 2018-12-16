module SpecUtils
  module File
    class Name < Spec
      attr_accessor :field_name
      before :generate, call: [:write_indent]
      after :generate, call: [:write_end]

      def initialize(file, klass, indent, field_name)
        super(file, klass, indent)
        self.field_name = field_name
      end

      def generate
        file.write("it 'stores file_name' do\n")
        write_indent
        file.write("\t\texpect(#{klass.to_s.underscore}.#{field_name}_file_name).to eq('missing.png')\n")
      end
    end

    class ContentType < Spec
      attr_accessor :field_name
      before :generate, call: [:write_indent]

      def initialize(file, klass, indent, field_name)
        super(file, klass, indent)
        self.field_name = field_name
      end

      def generate
        file.write("it 'stores content_type' do\n")
        write_indent
        file.write("\t\texpect(#{klass.to_s.underscore}.#{field_name}_content_type).to eq('image/png')\n")
        write_indent
        file.write("end\n")
      end
    end

    class Size < Spec
      attr_accessor :field_name
      before :generate, call: [:write_indent]

      def initialize(file, klass, indent, field_name)
        super(file, klass, indent)
        self.field_name = field_name
      end

      def generate
        file.write("it 'stores file_size' do\n")
        write_indent
        file.write("\t\texpect(#{klass.to_s.underscore}.#{field_name}_file_size).to eq(95)\n")
        write_indent
        file.write("end\n")
      end
    end

    class UpdatedAt < Spec
      attr_accessor :field_name
      before :generate, call: [:write_indent]

      def initialize(file, klass, indent, field_name)
        super(file, klass, indent)
        self.field_name = field_name
      end

      def generate
        file.write("it 'stores updated_at' do\n")
        write_indent
        file.write("\t\texpect(#{klass.to_s.underscore}.#{field_name}_updated_at).to be_present\n")
        write_indent
        file.write("end\n")
      end
    end

    class Fingerprint < Spec
      attr_accessor :field_name
      before :generate, call: [:write_indent]

      def initialize(file, klass, indent, field_name)
        super(file, klass, indent)
        self.field_name = field_name
      end

      def generate
        file.write("it 'stores fingerprint' do\n")
        write_indent
        file.write("\t\texpect(#{klass.to_s.underscore}.#{field_name}_fingerprint).to eq('71a50dbba44c78128b221b7df7bb51f1')\n")
        write_indent
        file.write("end\n")
      end
    end
  end
end
