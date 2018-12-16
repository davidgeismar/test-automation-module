class Spec
  attr_accessor :klass, :file, :indent
  include Indentation
  include Hooks
  # before :generate, call: :write_indent

  def initialize(file, klass, indent=nil)
    self.klass = klass
    self.file = file
    self.indent = indent
  end

  def generate
    raise "generate method must be implemented"
  end
end
