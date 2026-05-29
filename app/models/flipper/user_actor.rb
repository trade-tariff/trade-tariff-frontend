module Flipper
  class UserActor
    def initialize(user_id)
      @user_id = user_id
    end

    def flipper_id
      "User:#{@user_id}"
    end
  end
end
