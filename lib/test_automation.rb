require 'singleton'
require_relative("../indentation")
require_relative("../hooks")
require_relative('./spec/spec.rb')
require_relative('./block/block.rb')
require_relative('./block/blocks.rb')
require_relative('./spec/specs.rb')
require_relative('./spec/datatable/datatable_spec.rb')
require_relative('./spec/enumerize/enumerize_spec.rb')
require_relative('./spec/file/file_spec.rb')
require_relative('./spec/general/general_spec.rb')
require_relative('./spec/mongoid/mongoid_spec.rb')
require_relative('./image_spec_block')
module TestAutomation
  def self.configure(options = nil, &block)
    if !options.nil?
      Configuration.instance.configure(options)
    end
  end

  class Configuration
    include Singleton
    attr_accessor :options

    def initialize
      self.options = {}
    end
    def configure(options ={})
      self.options= options
    end
  end
end
