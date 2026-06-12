module Flagsmith
  class AnonymousIdentity
    attr_reader :identifier

    def initialize(uuid)
      @identifier = "Anonymous:#{uuid}"
    end
  end
end
