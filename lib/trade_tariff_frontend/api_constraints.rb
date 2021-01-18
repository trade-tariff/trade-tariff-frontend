module TradeTariffFrontend
  class ApiConstraints
    def initialize(endpoints)
      @endpoints = Array(endpoints)
    end

    def matches?(req)
      (Array(req.headers['Accept']).include?('application/json') || req['format'] == 'json') &&
        req['endpoint'].in?(@endpoints)
    end
  end

  class ApiPubConstraints
    def initialize(endpoints)
      @endpoints = Array(endpoints)
    end

    def matches?(req)
      req['path'].split('/')[0].in?(@endpoints)
    end
  end
end
