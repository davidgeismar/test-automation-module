class Block
  include Indentation
  include Hooks
  attr_accessor :file, :indent, :klass

  def initialize(file, klass, indent=nil)
    self.file = file
    self.indent = indent
    self.klass = klass
  end

  def generate
    yield if block_given?
  end
end
