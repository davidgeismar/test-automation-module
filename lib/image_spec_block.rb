require_relative("./block/blocks")
require_relative("./spec/file/file_spec")
class ImageSpec < Spec
  attr_accessor :instances
  def initialize(file, klass, instances, indent)
    super(file, klass, indent)
    self.instances = instances
  end

  def generate
    ::BlockUtils::Before.new(file, klass, nil, indent).generate do
      instances.each do |instance|
        if klass.validators.select{ |val| val.attributes.include?(instance.to_sym) && val&.options[:content_type]==/\Aimage\/.*\Z/}.present?
          write_indent
          file.write("\t#{klass.to_s.underscore}.update #{instance.to_s}: File.new('app/assets/images/missing/missing.png', 'rb')\n")
        end
      end
    end
    instances.each do |instance|
      if klass.validators.select{ |val| val.attributes.include?(instance.to_sym) && val&.options[:content_type]==/\Aimage\/.*\Z/}.present?
        ::SpecUtils::File::Name.new(file, klass, indent, instance).generate
        ::SpecUtils::File::ContentType.new(file, klass, indent, instance).generate
        ::SpecUtils::File::Size.new(file, klass, indent, instance).generate
        ::SpecUtils::File::UpdatedAt.new(file, klass, indent, instance).generate
        ::SpecUtils::File::Fingerprint.new(file, klass, indent, instance).generate
      end
    end
  end
end
