module GreenLanes
  class Exemption
    include XiOnlyApiEntity

    attr_accessor :code, :description, :formatted_description
  end
end
