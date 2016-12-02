module RabbitmqProcedureCall
  # Generate an uniq route name
  class RouteNameGenerator
    def self.call(prefix = '')
      prefix.strip!
      uuid = SecureRandom.uuid
      if prefix == ''
        uuid
      else
        "#{prefix}-#{uuid}"
      end
    end
  end
end
