class Specs
  attr_accessor :klass, :file, :instances, :spec_kind, :indent, :spec_args

  def initialize(file, klass, instances=nil, spec_kind, spec_args, indent)
    self.klass = klass
    self.file = file
    self.spec_kind = spec_kind
    self.instances = instances
    self.indent = indent
    self.spec_args = spec_args
  end

  def generate
    if instances
      instances.each do |instance|
        spec_kind.new(file, klass, indent, instance).generate
      end
    elsif spec_args
      spec_kind.new(file, klass, indent, spec_args).generate
    else
      spec_kind.new(file, klass, indent).generate
    end
  end
end
