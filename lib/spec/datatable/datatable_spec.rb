module SpecUtils
  module Datatable
    class ExcludeFields < Spec
      before :generate, call: [:write_indent]
      def generate
        file.write("it { expect(#{klass}.datatable_exclude_fields).to match_array %w(#{klass.datatable_exclude_fields.join(" ")}) }\n")
      end
    end
    class Fields < Spec
      before :generate, call: [:write_indent]
      def generate
        file.write("it { expect(#{klass}.datatable_fields).to match #{klass.datatable_fields} }\n")
      end
    end
    class SearchFields < Spec
      before :generate, call: [:write_indent]
      def generate
        file.write("it { expect(#{klass}.datatable_search_fields).to match  #{klass.datatable_search_fields} }\n")
      end
    end

    class Config < Spec
      before :generate, call: [:write_indent]
      def generate
        file.write("it { expect(#{klass}.datatable_config('http://example.com')).to include 'ajax', 'pagingType', 'serverSide', 'pageLength', 'columns', 'language' }\n")
      end
    end
  end
end
