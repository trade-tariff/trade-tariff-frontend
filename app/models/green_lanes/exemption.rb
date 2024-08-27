module GreenLanes
  class Exemption
    include XiOnlyApiEntity

    attr_accessor :code, :description, :formatted_description

    def display_code
      code.start_with?('WFE') ? '' : code
    end
  end
end
