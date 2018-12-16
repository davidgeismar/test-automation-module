module SpecUtils
  module Enumerize
    class Base < Spec
      before :generate, call: [:write_indent]
      attr_accessor :attribute

      def initialize(file, klass, indent=nil, attribute={})
        super(file, klass, indent)
        self.attribute = attribute
      end

      def generate

        if attribute.last.i18n_scope
          file.write("it { is_expected.to enumerize(:#{attribute.last.name}).in(#{attribute.last.values}).with_i18n_scope(['#{attribute.last.i18n_scope.first}']) } \n")
        else
          file.write("it { is_expected.to enumerize(:#{attribute.last.name}).in(#{attribute.last.values}) } \n")
        end
      end
    end
  end
end
