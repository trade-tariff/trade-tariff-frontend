module Flagsmith
  class UserIdentity
    attr_reader :identifier

    def initialize(user_id)
      @identifier = "User:#{user_id}"
    end
  end
end
