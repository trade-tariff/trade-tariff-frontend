module GreenLanes
  class Theme
    include XiOnlyApiEntity

    attr_accessor :category,
                  :theme

    alias_method :section, :resource_id

    def find(_id, _opts = {})
      raise NoMethodError, 'This method is not implemented'
    end

    def to_s
      "#{section} #{theme}"
    end
  end
end
