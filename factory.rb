class Factory
  attr_accessor :klass, :file, :excluded

  include Indentation
  include Hooks

  def initialize(klass, file, excluded=[])
    self.klass = klass
    self.file = file
    if klass.try(:attachment_definitions) && klass.attachment_definitions.present?
      self.excluded = klass.attachment_definitions.keys.map(&:to_s)
    end
  end

  def generate_fields
    klass.fields.each do |field|
      if is_not_excluded(field.last.name)
        case field.last.type.to_s
        when "Integer"
          file.write("\t\t#{field.last.name} {rand(1..100000)}\n")
        when "String"
          if field.last.name.include?("description") || field.last.name.include?("use_terms")
            file.write("\t\t#{field.last.name} { FFaker::HTMLIpsum.fancy_string }\n")
          elsif field.last.name.include?("email")
            file.write("\t\t#{field.last.name} { FFaker::Internet.email }\n")
          elsif field.last.name.include?("address")
            file.write("\t\t#{field.last.name} { FFaker::AddressFR.full_address }\n")
          elsif field.last.name.include?("reference")
            file.write("\t\t#{field.last.name} { FFaker::Product.model }\n")
          elsif field.last.name.include?("uid")
            file.write("\t\t#{field.last.name} { FFaker::Guid.guid }\n")
          elsif field.last.name.include?("first_name")
            file.write("\t\t#{field.last.name} { FFaker::NameFR.first_name}\n")
          elsif field.last.name.include?("last_name")
            file.write("\t\t#{field.last.name} { FFaker::NameFR.last_name}\n")
          elsif field.last.name.include?("phone_number")
            file.write("\t\t#{field.last.name} { FFaker::PhoneNumberFR.phone_number}\n")
          else
            file.write("\t\t#{field.last.name} { FFaker::NameFR.name }\n")
          end
        when "Date"
          file.write("\t\t#{field.last.name} { Date.today }\n")
        when "Boolean"
          file.write("\t\t#{field.last.name} { [true, false].sample }\n")
        end
      end
    end
  end



  def generate_belongs_to_association
    klass.reflect_on_all_associations(:belongs_to).each do |association|
      if association.class_name
        file.write("\t\t#{association.name} { create(:#{association.class_name.to_s.underscore}) }\n")
      else
        file.write("\t\t#{association.name} { create(:#{association.name}) }\n")
      end
    end if klass.reflect_on_all_associations(:belongs_to).present?
  end

  def generate_many_to_many_associations
    fields_with_presence_validator = klass.validators
                                    .select{|validator| validator.is_a? Mongoid::Validatable::PresenceValidator}
                                    .map{|presence_validator| presence_validator.attributes.first}
    many_to_many_associations = klass.reflect_on_all_associations(:has_and_belongs_to_many).map{|asso| asso.name}

    after_build_fields = many_to_many_associations.keep_if{|asso| fields_with_presence_validator.include?(asso)}
    if after_build_fields.present?
      file.write("\t\tafter(:build) do |#{klass.to_s.underscore}|\n")
      after_build_fields.each do |association|
        file.write("\t\t\t#{klass.to_s.underscore}.#{association}.push build_list(:#{association.to_s.singularize}, 2)\n")
      end
      file.write("\t\tend\n")
    end
  end
  def generate_enumerized_attributes
    klass.enumerized_attributes.attributes.each do |attribute|
      file.write("\t\t#{attribute.last.name.to_s} #{klass}.#{attribute.last.name.to_s}.values.sample\n" )
    end if klass.try(:enumerized_attributes) && klass.enumerized_attributes.present?
  end

  def generate_attachments
    klass.attachment_definitions.each do |attachment_definition|
      field = attachment_definition.first
      if klass.validators.select{ |val| val.attributes.include?(field.to_sym) && val&.options[:content_type]==/\Aimage\/.*\Z/}.present?
        file.write("\t\t#{attachment_definition.first} { File.new(Rails.root.join('app', 'assets', 'images', 'missing', 'missing.png')) }\n")
      end
    end if klass.try(:attachment_definitions) && klass.attachment_definitions.present?
  end

  def generate
    file.write("FactoryGirl.define do \n")
    file.write("\tfactory :#{klass.to_s.underscore}, class: #{klass} do\n")
    generate_fields
    generate_enumerized_attributes
    generate_attachments
    generate_belongs_to_association
    generate_many_to_many_associations
    file.write("\tend\n")
    file.write("end\n")
  end

  private

  def is_not_excluded(field)
    !field.starts_with?(*self.excluded)
  end

end
