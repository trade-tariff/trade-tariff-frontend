module Flipper
  class AnonymousActor
    def initialize(uuid)
      @uuid = uuid
    end

    def flipper_id
      "Anonymous:#{@uuid}"
    end
  end
end
