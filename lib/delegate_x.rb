class Module
  
  # like delegate only better
  def delegate_x(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options.delete(:to)
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key"
    end

    methods.concat(options.keys)

    unless methods.any?
      raise ArgumentError, "No delegated methods specified. Specify :method => :target_method or list methods"
    end

    methods.each do |method|
      target_method = options[method]||method
      module_eval(<<-EOS, "(__DELEGATIONX__)", 1)
        def #{ method }(*args, &block)
          #{to}.__send__(#{target_method.inspect},*args, &block) if #{to}
        end
      EOS
    end
  end
  
end