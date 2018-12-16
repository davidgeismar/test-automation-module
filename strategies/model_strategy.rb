require_relative('strategies')
TestAutomation::Strategies.class_eval do
  def self.model_strategy(klass)
    [
      {
        klass: ::BlockUtils::RSpec,
        args: [ "model"],
        block: [
          {
            klass: ::BlockUtils::Context,
            args: ["MONGOID"],
            block:[
              {
                klass: ::Specs,
                args: [nil, SpecUtils::Mongoid::Timestamp, nil]
              },
              {
                klass: ::Specs,
                args: [nil, SpecUtils::Mongoid::StoredIn, nil]
              },
              {
                klass: ::Specs,
                args: [nil, ::SpecUtils::General::Kind, Mongoid::Document]
              },
              {
                klass: ::Specs,
                args: [nil, ::SpecUtils::General::Kind, Mongoid::Slug]
              },
              {
                klass: ::BlockUtils::Context,
                args: ["fields"],
                block: [
                  {
                    klass: ::Specs,
                    args: [klass.fields, ::SpecUtils::Mongoid::Document, nil]
                  }
                ]
              },
              {
                klass: ::BlockUtils::Context,
                args: [ "enumerize_fields"],
                block: [
                  {
                    klass: ::Specs,
                    args: [klass.enumerized_attributes.attributes, ::SpecUtils::Enumerize::Base, nil]
                  }
                ]
              },
              {
                klass: ::BlockUtils::Context,
                args: [ "associations"],
                block: [
                  {
                    klass: ::Specs,
                    args: [klass.reflect_on_all_associations(:belongs_to, :has_many, :has_and_belongs_to_many, :embedded_in), ::SpecUtils::Mongoid::Association, nil]
                  }
                ]
              },
              {
                klass: ::BlockUtils::Context,
                args: ["validations"],
                block: [
                  {
                    klass: ::Specs,
                    args: [klass.validators, ::SpecUtils::Mongoid::Validation, nil]
                  }
                ]
              },
              {
                klass: ::BlockUtils::Context,
                args: [ "indices"],
                block: [
                  {
                    klass: ::Specs,
                    args: [klass.index_specifications, ::SpecUtils::Mongoid::Index,nil]
                  }
                ]
              },
              {
                klass: ::BlockUtils::Context,
                args: ["instance methods"],
                block: [
                  {
                    klass: ::Specs,
                    args: [klass.instance_methods(false).select {|m| klass.instance_method(m).source_location.first.ends_with? "/#{klass.to_s.downcase}.rb"}, ::SpecUtils::General::InstanceMethod, nil]
                  }
                ]
              },
              {
                klass: ::BlockUtils::Context,
                args: [ "paperclip_files"],
                block: [
                  {
                    klass: ::ImageSpec,
                    args: [klass.attachment_definitions.keys]
                  }
                ]
              },
              {
                klass: ::BlockUtils::Context,
                args: ["Datatable"],
                block: [
                  {
                    klass: ::BlockUtils::Describe,
                    args: ['datatable_exclude_fields'],
                    block: [
                      {
                        klass: ::Specs,
                        args: [nil, ::SpecUtils::Datatable::ExcludeFields, nil]
                      }
                    ]
                  },
                  {
                    klass: ::BlockUtils::Describe,
                    args: ['datatable_fields'],
                    block: [
                      {
                        klass: ::Specs,
                        args: [nil, ::SpecUtils::Datatable::Fields, nil]
                      }
                    ]
                  },
                  {
                    klass: ::BlockUtils::Describe,
                    args: [ 'datatable_search_fields'],
                    block: [
                      {
                        klass: ::Specs,
                        args: [nil, ::SpecUtils::Datatable::SearchFields, nil]
                      }
                    ]
                  },
                  {
                    klass: ::BlockUtils::Describe,
                    args: [ 'datatable_config'],
                    block: [
                      {
                        klass: ::Specs,
                        args: [nil, ::SpecUtils::Datatable::Config, nil]
                      }
                    ]
                  }
                ]
              },
            ]
          }
        ]
      }
    ]
  end
end
