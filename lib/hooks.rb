# require_relative('context_block_generator')
module Hooks

def self.included(base)
 base.send :extend, ClassMethods
end


module ClassMethods
  # everytime we add a method to the class we check if we must redifine it
  def method_added(method)

    if (@hookers_before.present? || @hookers_after.present?) && (@method_to_hook_to == method) && !@methods_seen.include?(method)
        begin
          method_to_hook_to = instance_method(@method_to_hook_to)
        rescue NameError => e
          return
        end
        hookers_before = []
        hookers_after =[]

        @hookers_before.each do |hooker_before|
          hookers_before.push instance_method(hooker_before) #.bind(self).call
        end if @hookers_before.present?

        @hookers_after.each do |hooker_after|
          hookers_after.push instance_method(hooker_after) #.bind(self).call
        end if @hookers_after.present?

        @methods_seen.push(method)
        define_method(method) do |*args, &block|
          hookers_before.each do |hooker|
            hooker.bind(self).call
          end
          method_to_hook_to.bind(self).(*args, &block) ## your old code in the method of the class
          hookers_after.each do |hooker|
            hooker.bind(self).call
          end
        end

      end
   end

  def before(method_to_hook_to, hookers)
   @method_to_hook_to = method_to_hook_to
   @hookers_before = hookers[:call]
   @methods_seen = []
  end

  def after(method_to_hook_to, hookers)
    @method_to_hook_to = method_to_hook_to
    @hookers_after = hookers[:call]
    @methods_seen = []
  end
 end
end
