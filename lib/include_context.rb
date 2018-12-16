require_relative('indentation')
require_relative('hooks')
class IncludeContext
  include Hooks
  include Indentation
  before :generate, call: [:write_indent]
  attr_accessor :context, :indent, :file
  def initialize(file, klass, context, indent)
    self.file = file
    self.klass = klass
    self.context = context
    self.indent = indent
  end

  def generate
    file.write("include_context '#{context}'\n")
  end
end
