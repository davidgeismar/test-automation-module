class Stub
  include Indentation
  include Hooks
  attr_accessor :file, :variable_name, :factory, :indent
  before :generate, call: [:write_indent]

  def initialize(file, klass, variable_name, factory, indent)
    self.variable_name = variable_name
    self.factory = factory
    self.file = file
    self.klass = klass
    self.indent = indent
  end

  def generate
    file.write("let(:#{variable_name}) { create(:#{factory}) }\n")
  end
end
