module DutyCalculator
  module RoutesHelper
    # TODO: When we need it, we can extend this to cover the other routes
    def current_route
      return :gb_to_ni if UserSession.get&.gb_to_ni_route?

      :row_to_ni
    end
  end
end
