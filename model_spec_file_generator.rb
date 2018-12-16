require 'pry-byebug'
require_relative 'test_procs'
require_relative 'specs_generator'
require_relative 'context_block_generator'
require_relative 'image_spec_block_generator'
require_relative 'instance_method_spec'
require_relative 'datatable_spec'
require_relative 'stub'
require_relative 'Factory'


class FactoryFile
  include TestProcs
  attr_accessor :klass,
                :file
  def initialize(klass, file)
    self.klass = klass
    self.file = file
  end

  def init_file_creation
    Factory.new(klass, file).generate
  end
end

class ModelTestFile

  include TestProcs
  attr_accessor :klass,
                :file,
                :generate_fields,
                :generate_enumerized_attributes,
                :generate_associations,
                :generate_validators,
                :generate_index_specifications

  def initialize(klass, file, generate_fields = true, generate_enumerized_attributes = true, generate_associations = true,
                 generate_validators = true, generate_index_specifications = true)
    self.klass = klass
    self.file = file
    self.generate_fields = generate_fields
    self.generate_enumerized_attributes = generate_enumerized_attributes
    self.generate_associations = generate_associations
    self.generate_validators = generate_validators
    self.generate_index_specifications = generate_index_specifications
  end

  def compare_to_last_snapshot
    # fetch last snapshot to remote database
    # compare last snapshot to current_db
    # propose a set of actions (rake tasks)
  end

  def init_test_creation


    modules = klass.included_modules

    # exclude unknown modules"#<Module:0x00007fe896c2be98>",
    highest_namespaces = (modules.map do|mod|
                              mod.to_s.split( '::' )[0].constantize unless mod.to_s.starts_with?("#")
                          end).uniq.compact
    # Mongoid
    # require 'rails_helper'
    file.write("require 'rails_helper'\n")
    RSpecBlock.new(file, klass, "model", 0).generate do
      if klass.try(:attachment_definitions) && klass.attachment_definitions.present?
        Stub.new(file, klass.to_s.underscore, klass.to_s.underscore, 1).generate
      end
       # check odm
      if highest_namespaces.include? Mongoid
        ContextBlock.new(file, "MONGOID", 1).generate do
          Specs.new(klass, file, nil, MongoidSpecs::TimestampSpec,nil, 2).generate
          Specs.new(klass, file, nil, MongoidSpecs::StoredInSpec,nil, 2).generate
          Specs.new(klass, file, nil, KindSpec, Mongoid::Document, 2).generate
          Specs.new(klass, file, nil, KindSpec, Mongoid::Slug, 2).generate
          if modules.include? Mongoid::Document
            #FIELDS
            ContextBlock.new(file, "fields", 2).generate do
              Specs.new(klass, file, klass.fields, MongoidSpecs::DocumentSpec, nil, 3).generate  if klass.fields.present?
            end
          end
          ContextBlock.new(file, "enumerize_fields", 2).generate do
            Specs.new(klass, file, klass.enumerized_attributes.attributes, EnumerizeSpecs::BaseSpec,nil, 3).generate  if (modules.include?(Enumerize::Base) && klass.enumerized_attributes.present?)
          end
          #ASSOCIATIONS
          if klass.reflect_on_all_associations(:belongs_to, :has_many, :has_and_belongs_to_many, :embedded_in).present?
              ContextBlock.new(file, "associations", 2).generate do
                Specs.new(klass, file, klass.reflect_on_all_associations(:belongs_to, :has_many, :has_and_belongs_to_many, :embedded_in), MongoidSpecs::AssociationSpec,nil, 3).generate
              end
           end
          # VALIDATORS
          if klass.validators.present?
            ContextBlock.new(file, "validations", 2).generate do
              Specs.new(klass, file, klass.validators, MongoidSpecs::ValidationSpec,nil, 3).generate
            end
          end
          #INDICES
          if klass.index_specifications.present?
            ContextBlock.new(file, "indices", 2).generate do
              Specs.new(klass, file, klass.index_specifications, MongoidSpecs::IndexSpec,nil, 3).generate
            end
          end
          # instance methods
          instance_methods = klass.instance_methods(false).select {|m| klass.instance_method(m).source_location.first.ends_with? "/#{klass.to_s.downcase}.rb"}
          if instance_methods.present?
            ContextBlock.new(file, "instance methods", 2).generate do
              Specs.new(klass, file, instance_methods, ::InstanceMethodSpec,nil, 3).generate
            end
          end
          # files
          if klass.try(:attachment_definitions) && klass.attachment_definitions.present? && klass.validators.select{ |val| val&.options[:content_type]==/\Aimage\/.*\Z/}.present?
            ContextBlock.new(file, "paperclip_files", 2).generate do
              ImageSpecBlock.new(klass, file, klass.attachment_definitions.keys, 3).generate
            end
          end
          # datatable
          if modules.include? Edulib::Datatable
            ContextBlock.new(file, "Datatable", 2).generate do
              if klass.datatable_exclude_fields.present?
                DescribeBlock.new(file, 'datatable_exclude_fields', 3).generate do
                  Specs.new(klass, file, nil, ::DatatableSpecs::ExcludeFieldsSpec,nil, 4).generate
                end
              end
              if klass.datatable_fields.present?
                DescribeBlock.new(file, 'datatable_fields', 3).generate do
                  Specs.new(klass, file, nil, ::DatatableSpecs::FieldsSpec,nil, 4).generate
                end
              end
              if klass.datatable_search_fields.present?
                DescribeBlock.new(file, 'datatable_search_fields', 3).generate do
                  Specs.new(klass, file,nil,  ::DatatableSpecs::SearchFieldsSpec,nil, 4).generate
                end
              end
              DescribeBlock.new(file, 'datatable_config', 3).generate do
                Specs.new(klass, file, nil, ::DatatableSpecs::ConfigSpec,nil, 4).generate
              end
            end
          end
        end
      end
    end
  end

  private

  def generate_specs(klass_method: klass_method, klass_method_args: klass_method_args, allow_generation: allow_generation, context_name: context_name, write_spec_proc: write_spec_proc)
    if klass.send(klass_method, *klass_method_args).present? && allow_generation
      file.write("\tcontext '#{context_name}' do \n")
      if klass_method_args.present?
        write_spec_proc.call klass, klass_method, klass_method_args
      else
        write_spec_proc.call klass.send(klass_method)
      end
      file.write("\tend \n")
    end
  end
end
