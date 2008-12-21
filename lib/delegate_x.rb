class Module
  
  # like delegate only better
  # built upon delegate_x from http://spongetech.wordpress.com/2008/02/12/delegate-to-the-giraffe/
  def delegate_x(*methods)
    options = methods.extract_options!

    unless to = options.delete(:to)
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key"
    end

    include_writers = options.delete(:include_writers)
    methods.concat(options.keys).flatten!

    unless methods.any?
      raise ArgumentError, "No delegated methods specified. Specify :method => :target_method or list methods"
    end

    methods.each do |method|
      target_method = options[method] || method
      module_eval(<<-EOS, "(__DELEGATIONX__)", 1)
        def #{ method }(*args, &block)
          #{to}.__send__(#{target_method.inspect}, *args, &block) if #{to}
        end
      EOS
      if include_writers
        module_eval(<<-EOS, "(__DELEGATIONX__)", 1)
          def #{ method }=(*args, &block)
            #{to}.__send__(#{(target_method.to_s + '=').inspect}, *args, &block) if #{to}
          end
        EOS
      end
    end
  end
  
end