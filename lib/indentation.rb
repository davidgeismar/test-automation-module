module Indentation
  def write_indent
    @indent.times{ @file.write("\t") }
  end

  def write_end
    write_indent
    @file.write("end \n")
  end
end
