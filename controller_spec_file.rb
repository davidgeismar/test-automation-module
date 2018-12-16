require 'pry-byebug'
require 'ffaker'
require 'factory_girl_rails'
require_relative 'test_procs'
require_relative 'specs_generator'
require_relative 'context_block_generator'
require_relative 'image_spec_block_generator'
require_relative 'instance_method_spec'
require_relative 'datatable_spec'
require_relative 'stub'
require_relative 'Factory'
require_relative 'include_context'



class ControllerTestFile

  include TestProcs
  attr_accessor :klass,
                :file

  def initialize(klass, file)
    self.klass = klass
    self.file = file
  end

  def init_test_creation
    model_associated_str = klass.to_s.demodulize.gsub("Controller", '').singularize
    full_model_associated = klass.to_s.gsub("Controller", '').underscore
    model_associated = klass.to_s.demodulize.gsub("Controller", '').singularize.constantize
    routes = route_extractor(full_model_associated)
    validators = model_associated.validators
                  .map{ |validator|
                    validator if (validator.is_a?(Mongoid::Validatable::PresenceValidator))
                  }.compact
    unique_attributes = validators.map(&:attributes).map(&:first).uniq
    file.write("require 'rails_helper'\n")
    RSpecBlock.new(file, klass,"controller", 0).generate do
      protected_controller_specs(routes)
      ContextBlock.new(file, "Params validation", 1).generate do
        stub_toolkit(model_associated, file)
        BeforeBlock.new(file, :each, 2) do
          file.write("sign in user")
        end
        Exemple.new(file, "should validate the presence of #{model_associated_str} parameter", 2).generate do
          actual = "{post 'create', {}}"
          expected = "raise_error ActionController::ParameterMissing"
          Expect.new(file, actual, expected, :to, 3).generate
        end
        ContextBlock.new(file, "Params validation inside {#{model_associated_str}: {}}", 2).generate do
          params_spec_for_model_associated(unique_attributes, model_associated_str, model_associated)
        end
        DescribeBlock.new(file, "CRUD for an #{model_associated_str}", 2).generate do
          if klass.to_s.deconstantize == "Admin"
            IncludeContext.new(file, "admin user", 3).generate
          end
          ContextBlock.new(file, "with valid attributes", 3).generate do
            # crud.each do |method, http_verb|
            routes.each do |route_helper, route_details|
              method = route_details.defaults[:action].to_sym
              http_verb = get_http_verb(route_details.constraints[:request_method])
              # if crud.keys.include?(rmethod.to_sym)
              Exemple.new(file, "#{http_verb.upcase} #{method} an #{model_associated_str}", 4).generate do
                if method == :create || method == :update
                  actual = "{ #{http_verb} :#{method}, #{model_associated_str.underscore}: #{create_valid_instance_json(model_associated)}}"
                  expected = "change(#{model_associated_str}, :count).by(1)"
                  Expect.new(file, actual, expected, :to, 5).generate
                  Expect.new(file, "(response)", "have_http_status(302)", :to, 5).generate
                elsif method == :new || method == :edit
                  # I need to know the route !!!
                  file.write("\t\t\t\t\t #{http_verb} :#{method}\n")
                  # extra = create_valid_instance_json(model_associated, model_associated_str)
                  actual = "(assigns(:#{model_associated_str.downcase}))"
                  expected = "to be_a_new #{model_associated}"
                  Expect.new(file, actual, expected, :to, 5).generate
                  Expect.new(file, "(response)", "be_success", :to, 5).generate
                  Expect.new(file, "(response)", "have_http_status(200)", :to, 5).generate
                  Expect.new(file, "(response)", "render_template :#{method}", :to, 5).generate
                end
              end
            end

            # Exemple.new(file, "create an #{model_associated_str}", 4).generate do
            #   extra = create_valid_instance_json(model_associated, model_associated_str)
            #   actual = "{ post :create, #{serialize_associations(model_associated, extra)}}"
            #   expected = "change(#{model_associated_str}, :count).by(1)"
            #   Expect.new(file, actual, expected, :to, 5).generate
            #   Expect.new(file, "(response)", "have_http_status(302)", :to, 5).generate
            # end

          end
        end
      end
    end
  end

  private

  def protected_controller_specs(routes)
    if is_protected_controller
      random_get_method = get_random_get_route(routes)
      Stub.new(file, "user", "user_with_acl", 1).generate
      Exemple.new(file, "should be a protected controller", 1).generate do
        file.write("\t\tsign_out user\n")
        file.write("\t\t get #{random_get_method}\n")
        Expect.new(file, "(response)", "be_success", :not_to, 2).generate
        Expect.new(file, "(response)", "have_http_status(302)", :to, 2).generate
      end
    end
  end

  def get_random_get_route(routes)
    routes.each do |route_helper, route_details|
      return route_details.defaults[:action] if route_details.constraints[:request_method] =~ "GET"
    end
  end
  def is_protected_controller
    klass.to_s.deconstantize == "Admin"
  end

  def route_extractor(full_model_associated)
    routes =   Rails.application.routes.named_routes.routes
    routes.each do |route_helper, route_details|
      routes.delete(route_helper) unless (route_details.defaults[:controller] == full_model_associated)
    end
    return routes
  end

  def create_invalid_instance(model_associated, to_merge)
    stub_hash = create_valid_instance_json(model_associated)
    if to_merge.is_a? Symbol
       stub_hash.delete(to_merge)
    else
      stub_hash.merge!(to_merge)
    end
    stub_hash.to_json.gsub!('"', '').gsub(/:/, ": ").gsub(/,/, ", ")
  end

  def create_valid_instance_json(klass)
    validators = klass.validators
                  .map{ |validator|
                    validator if (validator.is_a?(Mongoid::Validatable::PresenceValidator))
                  }.compact
    unique_attributes = validators.map(&:attributes).map(&:first).uniq
    hash = {}
    unique_attributes.each do |attribute|
      if klass.reflect_on_all_associations(:belongs_to).map{|asso| asso.name}.include? attribute
        hash["#{attribute.to_s}_id"] = "#{attribute.to_s}.id"
      else
        hash[attribute] = define_mock_value(klass, attribute)
      end
    end
    return hash
  end

  def serialize_associations(model_associated, extra=nil)
    hash = {}
    model_associated.reflect_on_all_associations(:belongs_to).each do |association|
      hash["#{association.name}_id"] = "#{association.name}.id"
    end
    hash.merge!(extra) if extra
    hash.to_json.gsub!('"', '').gsub(/:/, ": ").gsub(/,/, ", ")
  end

  def define_mock_value(klass, attribute)
    if klass.enumerized_attributes.attributes.keys.include?(attribute.to_s)
      return "#{klass}.#{attribute.to_s}.values.sample"
    end
    unless klass.reflect_on_all_associations(:belongs_to).map{|asso| asso.name}.include? attribute
      case klass.fields[attribute.to_s].options[:type].to_s
      when "Integer"
        return "Random.rand(0...1000000000000)"
      when "Boolean"
        return "[true, false].sample"
      when "String"
        return "FFaker::NameFR.name"
      end
    end
  end
  def stub_toolkit(model_associated, file)
    model_associated.reflect_on_all_associations(:belongs_to).each do |association|
      Stub.new(file, association.name, association.name, 2).generate
    end
  end

  def get_http_verb(regex_from_route)
    if  regex_from_route.match('POST')
      return :post
    elsif regex_from_route.match('PATCH')
      return :put
    elsif regex_from_route.match('GET')
      return :get
    elsif regex_from_route.match('DELETE')
      return :delete
    elsif regex_from_route.match('PUT')
      return :put
    end
  end

  def params_spec_for_model_associated(unique_attributes, model_associated_str, model_associated)
    unique_attributes.each do |attribute|
      ContextBlock.new(file, attribute.to_s, 3).generate do
        Exemple.new(file, "should validate the presence of #{attribute.to_s}", 4).generate do
          actual = "{post 'create', #{model_associated_str.underscore}: #{create_invalid_instance(model_associated, attribute)}}"
          expected = "raise_error(RailsParam::Param::InvalidParameterError) { |e| expect(e.param).to(eq('#{attribute.to_s}')); expect(e.message).to(match(/required/));}"
          Expect.new(file, actual, expected, :to, 5).generate
        end
        Exemple.new(file, "should validate that #{attribute.to_s} is not blank", 4).generate do
          extra = {}
          extra[attribute] = "nil"
          actual = "{post 'create', #{model_associated_str.underscore}: #{create_invalid_instance(model_associated, extra)}}"
          expected = "raise_error(RailsParam::Param::InvalidParameterError) { |e| expect(e.param).to(eq('#{attribute.to_s}')); expect(e.message).to(match(/required/));}"
          Expect.new(file, actual, expected, :to, 5).generate
          extra[attribute] = "''"
          actual = "{post 'create', #{model_associated_str.underscore}: #{create_invalid_instance(model_associated, extra)}}"
          Expect.new(file, actual, expected, :to, 5).generate
        end
        if model_associated.enumerized_attributes.attributes.keys.include?(attribute.to_s)
          Exemple.new(file, "should be within enumerize values", 4).generate do
            extra = {}
            extra[attribute] = 'test'
            actual = "{post 'create', #{model_associated_str.underscore}:  #{create_invalid_instance(model_associated, extra)}}"
            expected = "raise_error(RailsParam::Param::InvalidParameterError) { |e| expect(e.param).to(eq('#{attribute.to_s}')); expect(e.message).to(match(#{model_associated.send(attribute).values}));}"
            Expect.new(file, actual, expected, :to, 5).generate
          end
        end
      end
    end
  end
end
