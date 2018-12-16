module SpecUtils
  module Mongoid
    class Document < Spec
      attr_accessor :attribute
      before :generate,  call: [:write_indent]
      def initialize(file, klass, indent=nil, attribute={})
        super(file, klass, indent)
        self.attribute = attribute
      end

      def generate
        if attribute.last.default_val && attribute.last.name != "_id" && attribute.last.default_val.is_a?(String)
          spec = "it { is_expected.to have_field(:#{attribute.last.name}).of_type(#{attribute.last.type}).with_default_value_of('#{attribute.last.default_val}') } \n"
        elsif attribute.last.default_val && attribute.last.name != "_id"
          spec = "it { is_expected.to have_field(:#{attribute.last.name}).of_type(#{attribute.last.type}).with_default_value_of(#{attribute.last.default_val}) } \n"
        else
          spec = "it { is_expected.to have_field(:#{attribute.last.name}).of_type(#{attribute.last.type})}\n"
        end
        file.write(spec)
      end
    end

    class StoredIn < Spec
      before :generate,  call: [:write_indent]

      def generate
        file.write("it { is_expected.to be_stored_in :#{klass.storage_options_defaults[:collection]} }\n")
      end
    end

    class Timestamp < Spec
      before :generate,  call: [:write_indent]

      def generate
        file.write("it { is_expected.to be_timestamped_document }\n")
      end
    end

    class Validation < Spec
      attr_accessor :validator

      def initialize(file, klass, indent=nil, validator)
        super(file, klass, indent)
        self.validator = validator
      end

      def generate
        if validator.instance_of? ::Mongoid::Validatable::PresenceValidator
          write_indent
          file.write("it { is_expected.to validate_presence_of(:#{validator.attributes.first}) }\n")
        elsif validator.instance_of? ::Mongoid::Validatable::UniquenessValidator
          write_indent
          file.write("it { is_expected.to validate_uniqueness_of(:#{validator.attributes.first}) }\n")
        end
      end
    end

    class Index < Spec
      attr_accessor :index
      before :generate, call: [:write_indent]

      def initialize(file, klass, indent=nil, index)
        super(file, klass, indent)
        self.index = index
      end

      def generate
        if index.options[:name]
          file.write("it { is_expected.to have_index_for(#{index.key}).with_options(name: '#{index.options[:name]}') }\n")
        else
          file.write("it { is_expected.to have_index_for(#{index.key}) }\n")
        end
      end
    end
  # it { is_expected.to be_embedded_in(:editor).of_type(Editor) }
    class Association < Spec
      attr_accessor :association
      before :generate, call: [:write_indent]

      def initialize(file, klass, indent=nil, association)
        super(file, klass, indent)
        self.association = association
      end

      def generate
        case association.relation.to_s
        when ::Mongoid::Relations::Referenced::In.to_s
          relation_verb = "belong_to"
          relation_klass = define_relation_klass(association)
        when ::Mongoid::Relations::Referenced::Many.to_s
          relation_verb = "have_many"
          relation_klass = define_relation_klass_many(association)
        when ::Mongoid::Relations::Referenced::ManyToMany.to_s
          relation_verb = "have_and_belong_to_many"
          relation_klass = define_relation_klass_many(association)
        when ::Mongoid::Relations::Embedded::In.to_s
          relation_verb = "be_embedded_in"
          relation_klass = define_relation_klass(association)
        end
        file.write("it { is_expected.to #{relation_verb}(:#{association.name}).of_type(#{relation_klass}) } \n")
      end

      def define_relation_klass(association)
        if association.class_name
          return association.class_name.constantize
        else
          return association.name.to_s.classify.constantize
        end
      end

      def define_relation_klass_many(association)
        if association.class_name
          return association.class_name.constantize
        else
          return association.name.to_s[0..-2].classify.constantize
        end
      end
    end
  end
end
